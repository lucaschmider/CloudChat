import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';

import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';

import 'package:cloud_chat/chat/bloc/models/chat_user.dart';

import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';

import 'package:cloud_chat/chat/bloc/models/chat_message.dart';

import 'package:cloud_chat/bloc/models/authentification_result.dart';
import 'package:cloud_chat/implementations/backendless/models/room.dart';
import 'package:cloud_chat/implementations/backendless/models/room_message.dart';
import 'package:cloud_chat/implementations/backendless/models/room_participant.dart';
import 'package:cloud_chat/implementations/backendless/models/user.dart';
import 'package:cloud_chat/implementations/backendless/utils/backendless_paths.dart';
import 'package:cloud_chat/implementations/backendless/utils/interceptors.dart';
import 'package:dio/dio.dart';

import '../../bloc/authentification_repository.dart';
import '../../chat/bloc/chat_repository.dart';
import '../../logger.dart';

class BackendlessRepository
    implements ChatRepository, AuthenticationRepository {
  final _httpClient =
      Dio(BaseOptions(baseUrl: "https://suavewall.backendless.app"));
  final Logger _logger;

  static String? _token;
  static String? currentUserId = "Initial";

  BackendlessRepository(this._logger) {
    _httpClient.interceptors.add(AutomaticTokenInterceptor(
      onTokenReceived: (token) {
        _logger.info("Received new token: $token");
        _token = token;
      },
      onTokenRequired: () => _token,
    ));
    _httpClient.interceptors.add(DefaultHeaderInterceptor(
      apiKey: "3888287B-EE71-4246-AFC9-4034152492BF",
      applicationId: "95B22E55-7B97-ED44-FFB3-46A479D95A00",
    ));
  }

  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) async {
    final row = RoomMessage.fromDomain(message, chatRoomId);

    await _httpClient.post(
      BackendlessPaths.roomMessagesPath,
      data: row.toMap(),
    );
  }

  @override
  Future<List<ChatUser>> getAllUsers() async {
    final response = await _httpClient.get(BackendlessPaths.userPath);
    final users = User.fromMaps(response.data);
    return users.map((e) => e.toDomain()).toList();
  }

  @override
  Future<InitialChatRoomState> getChatRoom(String chatRoomId) async {
    final responses = await Future.wait([
      _httpClient.get(
          "${BackendlessPaths.roomsPath}?where=roomId%20%3D%20%27$chatRoomId%27"),
      _httpClient.get(
          "${BackendlessPaths.roomMessagesPath}?where=roomId%20%3D%20%27$chatRoomId%27"),
      _httpClient.get(
          "${BackendlessPaths.roomParticipantsPath}?where=roomId%20%3D%20%27$chatRoomId%27"),
      _httpClient.get(BackendlessPaths.userPath),
    ]);

    final room = Room.fromMaps(responses[0].data).first;
    final messages = RoomMessage.fromMaps(responses[1].data);
    final participants = RoomParticipant.fromMaps(responses[2].data);
    final allUsers = User.fromMaps(responses[3].data);

    return InitialChatRoomState(
      messages: messages.map((e) => e.toDomain()).toList(),
      metadata: ChatRoomMetadata(
        chatRoomId: chatRoomId,
        name: room.name,
        participants: participants.map((e) => e.toDomain(allUsers)).toList(),
      ),
    );
  }

  @override
  Stream<InitialChatRoomState> getChatRoomStream(String chatRoomId) =>
      Stream.periodic(const Duration(milliseconds: 500))
          .asyncMap((event) => getChatRoom(chatRoomId));

  @override
  Stream<UserChangedEvent> getUserStream() =>
      Stream.periodic(const Duration(milliseconds: 500)).asyncMap((trip) async {
        if (currentUserId == null) return const UserChangedEvent(null, null);
        final responses = await Future.wait([
          _httpClient.get(
              "${BackendlessPaths.userPath}?where=userId%20%3D%20%27$currentUserId%27"),
          _httpClient.get(
              "${BackendlessPaths.roomParticipantsPath}?where=userId%20%3D%20%27$currentUserId%27"),
          _httpClient.get(BackendlessPaths.roomsPath),
        ]);

        final user = User.fromMaps(responses[0].data).first;
        final participants = RoomParticipant.fromMaps(responses[1].data);
        final rooms = Room.fromMaps(responses[2].data);

        return UserChangedEvent(
            user.toDomain(),
            participants.map((e) {
              final r =
                  rooms.singleWhere((element) => element.roomId == e.roomId);
              return ChatRoomOption(
                isSelected: false,
                chatRoomId: e.roomId,
                name: r.name,
              );
            }).toList());
      });

  @override
  Future<bool> isCurrentProfileCompleted() async {
    final response = await _httpClient.get(
        "${BackendlessPaths.userPath}/count?where=userId%20%3D%20%27$currentUserId%27");
    final profileCount = response.data as int;
    return profileCount > 0;
  }

  @override
  Future<void> setFullName(String fullName) =>
      _httpClient.post(BackendlessPaths.userPath, data: {
        "userId": currentUserId,
        "name": fullName,
      });

  @override
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
      String username, String password) async {
    final response = await _httpClient.post(BackendlessPaths.loginPath, data: {
      "login": username,
      "password": password,
    });

    currentUserId = response.data["objectId"];
    _logger.info("Performed login for user with id $currentUserId");
    return AuthentificationResult.success;
  }

  @override
  Future<void> signOut() => _httpClient.get(BackendlessPaths.logoutPath);

  @override
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
      String username, String password) async {
    await _httpClient.post(BackendlessPaths.registerPath, data: {
      "email": username,
      "password": password,
    });

    await Future.delayed(const Duration(milliseconds: 400));

    return await signInWithUsernameAndPasswordAsync(username, password);
  }

  @override
  Future<void> updateChatRoom(ChatRoomMetadata metadata) => Future.wait([
        _setChatRoomName(metadata),
        _updateParticipants(metadata.chatRoomId, metadata.participants),
      ]);

  Future<void> _updateParticipants(
      String chatRoomId, List<ChatUser> participants) async {
    await _httpClient.delete(
        "${BackendlessPaths.bulkRoomParticipantsPath}?where=roomId%20%3D%20%27$chatRoomId%27");

    final rows = RoomParticipant.fromDomain(participants, chatRoomId)
        .map((e) => e.toMap())
        .toList();

    await _httpClient.post(
      BackendlessPaths.bulkRoomParticipantsPath,
      data: rows,
    );
  }

  Future<void> _setChatRoomName(ChatRoomMetadata metadata) async {
    await _httpClient.delete(
        "${BackendlessPaths.bulkRoomPath}?where=roomId%20%3D%20%27${metadata.chatRoomId}%27");

    _httpClient.post(
      BackendlessPaths.roomsPath,
      data: Room.fromDomain(metadata).toMap(),
    );
  }
}
