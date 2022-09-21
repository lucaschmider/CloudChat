import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';

import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';

import 'package:cloud_chat/chat/bloc/models/chat_user.dart';

import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';

import 'package:cloud_chat/chat/bloc/models/chat_message.dart';

import 'package:cloud_chat/bloc/models/authentification_result.dart';
import 'package:cloud_chat/implementations/appwrite/models/get_all_users_response.dart';
import 'package:cloud_chat/implementations/appwrite/utils/database_mappers.dart';

import 'package:cloud_chat/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../bloc/authentification_repository.dart';
import '../../chat/bloc/chat_repository.dart';

class AppwriteRepository implements ChatRepository, AuthenticationRepository {
  static AppwriteRepository? _instance;
  static const uuid = Uuid();
  static const roomCollection = "6311f606a5c2c89995b9";
  static const roomMessageCollection = "631de69222af00a5dfa9";
  static const getAllUsersFunction = "getAllUsers";
  static const getMyRoomsFunction = "getMyRooms";
  static const databaseId = "6311f53043761d11f812";
  static const accountScope = "account";

  final collectionIdPattern = RegExp(
      "(?<=databases\\.6311f53043761d11f812\\.collections\\.)[0-9a-z]{20}(?=\\.documents\\.[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12})");

  final Client _client;
  final Logger _logger;

  late final _auth = Account(_client);
  late final _realtime = Realtime(_client);
  late final _database = Databases(
    _client,
    databaseId: databaseId,
  );
  late final _functions = Functions(_client);

  StreamSubscription? _realtimeSubscription;

  final currentRoomSubject = PublishSubject<InitialChatRoomState>();
  final userChangedSubject = PublishSubject<String>(
      onListen: () => print("Listening to userChangedSubject"));

  static getInstance(Logger logger) {
    _instance ??= AppwriteRepository(logger);
    return _instance;
  }

// TODO: Permissions müssen immer gesetzt sein => role:all muss hinzugefügt werden
  AppwriteRepository(this._logger)
      : _client = Client()
            .setEndpoint('http://13.73.148.57/v1')
            .setProject('630cb8e5d2403e179f24');

  void _updateRealtime(String chatRoomId) {
    _realtimeSubscription?.cancel();

    // TODO: Mechanismus gut übernommen, manuelles aufteilen der Events ist notwendig
    _realtimeSubscription = _realtime
        .subscribe([
          // TODO: Realtime API nicht so mächtig wie firebase, neuladen notwendig um mitzubekommen, wenn neuer raum verfügbar ist
          // TODO: Alternative wäre die speicherung der Räume mit zugriff im profil => Raumupdate führt zu Update in allen User Dokumenten
          // TODO: Deshalb muss neugeladen werden um neuen raum zu sehen
          "databases.$databaseId.collections.$roomCollection.documents.$chatRoomId",
          "databases.$databaseId.collections.$roomMessageCollection.documents",
        ])
        .stream
        .listen((event) async => getChatRoom(chatRoomId)
            .then((value) => currentRoomSubject.add(value)));
  }

  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    final docId = uuid.v4();

    return _database.createDocument(
      collectionId: roomMessageCollection,
      documentId: docId,
      data: {
        "chatRoomId": chatRoomId,
        "sender": message.userId,
        "text": message.text,
        "timestamp": message.timestamp.toIso8601String(),
      },
    );
  }

// TODO: Es gibt keine Clientseitige Api um alle Nutzer zu laden, serverseitig möglich
  @override
  Future<List<ChatUser>> getAllUsers() async {
    final execution = await _functions.createExecution(
      functionId: getAllUsersFunction,
      xasync: false,
    );

    final response = jsonDecode(execution.response);
    final data = GetAllUsersResponse.fromMap(response);
    return data.allUsers;
  }

  @override
  Future<InitialChatRoomState> getChatRoom(String chatRoomId) async {
    // TODO: Index erforderlich um suche zu starten
    final responses = await Future.wait([
      _database.getDocument(
        collectionId: roomCollection,
        documentId: chatRoomId,
      ),
      _database.listDocuments(
        collectionId: roomMessageCollection,
        queries: [
          Query.equal("chatRoomId", chatRoomId),
        ],
      ),
      getAllUsers(),
    ]);
    final document = responses[0] as Document;
    final messages = responses[1] as DocumentList;
    final allUsers = responses[2] as List<ChatUser>;

    return DatabaseMappers.parseInitialChatRoomState(
      data: document.data,
      chatRoomId: chatRoomId,
      allUsers: allUsers,
      messages: messages,
    );
  }

  @override
  Stream<InitialChatRoomState> getChatRoomStream(String chatRoomId) {
    _updateRealtime(chatRoomId);
    return currentRoomSubject.stream;
  }

  @override
  Stream<UserChangedEvent> getUserStream() =>
      // TODO: Functions Architektur seltsam, eigenes node projekt pro function => sehr großer speicher platz während der entwicklung (npm)
      // TODO: Query API nicht so mächtig, lade alle Dokumente und filtere lokal
      userChangedSubject.asyncMap((event) async {
        _logger.info("User Changed Map");
        final currentUser = await _auth.get();

        final initialRequest = await _database.listDocuments(
            collectionId: roomCollection, limit: 100);
        final documents = [...initialRequest.documents];

        while (documents.length < initialRequest.total) {
          final currentBatch = await _database.listDocuments(
            collectionId: roomCollection,
            limit: 100,
            offset: documents.length,
          );
          documents.addAll(currentBatch.documents);
        }

        final options = documents
            .where((element) {
              final pRaw = element.data["participants"] as List<dynamic>;
              final participants = pRaw.map((e) => e as String);
              return participants.contains(currentUser.$id);
            })
            .map((e) => ChatRoomOption(
                  isSelected: false,
                  chatRoomId: e.$id,
                  name: e.data["name"],
                ))
            .toList();

        return UserChangedEvent(
          ChatUser(
            name: currentUser.name,
            userId: currentUser.$id,
          ),
          options,
        );
      });

  @override
  Future<bool> isCurrentProfileCompleted() async {
    final currentUser = await _auth.get();
    return currentUser.name.isNotEmpty;
  }

  @override
  Future<void> setFullName(String fullName) => _auth.updateName(name: fullName);

  @override
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
      String username, String password) async {
    try {
      await _auth.createEmailSession(email: username, password: password);
      _logger.info("Successfully signed in in as $username");
      Future.delayed(const Duration(milliseconds: 300))
          .then((value) => userChangedSubject.add("event"));
      return AuthentificationResult.success;
    } on Exception catch (e) {
      _logger.error("Failed to login user $username", exception: e);
      return AuthentificationResult.unknownError;
    }
  }

  @override
  Future<void> signOut() => _auth.deleteSessions();

  @override
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
      String username, String password) async {
    try {
      await _auth.create(
        userId: const Uuid().v4(),
        email: username,
        password: password,
      );
      _logger.info("Successfully signed up in as $username");
      // TODO: Kein automatischer login wenn man sich registriert
      final result =
          await signInWithUsernameAndPasswordAsync(username, password);

      userChangedSubject.add("");
      return result;
    } on Exception catch (e) {
      _logger.error("Failed to create user $username", exception: e);
      return AuthentificationResult.unknownError;
    }
  }

  @override
  Future<void> updateChatRoom(ChatRoomMetadata metadata) async {
    final data = DatabaseMappers.mapChatRoomMetadata(metadata);

    // TODO: Exception muss zur Flusssteuerung verwendet werden, da keine API existiert um die Existenz eines Dokuments zu prüfen und update nicht genutzt werden kann um Dokumente zu erstellen.
    // TODO: Schema muss angegeben werden obwohl "no sql" datenbank => in wahrheit ist maria db im hintergrund (zu sehen in der docker-compose.yml)
    try {
      await _database.getDocument(
        collectionId: roomCollection,
        documentId: metadata.chatRoomId,
      );

      await _database.updateDocument(
        collectionId: roomCollection,
        documentId: metadata.chatRoomId,
        data: data,
      );
    } on AppwriteException catch (e) {
      if (e.type != "document_not_found") rethrow;

      await _database.createDocument(
        collectionId: roomCollection,
        documentId: metadata.chatRoomId,
        data: data,
      );
    }
  }
}
