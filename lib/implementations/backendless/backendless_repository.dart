import 'dart:async';

import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';

import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';

import 'package:cloud_chat/chat/bloc/models/chat_user.dart';

import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';

import 'package:cloud_chat/chat/bloc/models/chat_message.dart';

import 'package:cloud_chat/bloc/models/authentification_result.dart';
import 'package:cloud_chat/implementations/backendless/models/room_message.dart';
import 'package:cloud_chat/implementations/backendless/models/room_participant.dart';
import 'package:cloud_chat/implementations/backendless/models/quadruple.dart';
import 'package:cloud_chat/implementations/backendless/models/user.dart';
import 'package:rxdart/rxdart.dart';

import '../../bloc/authentification_repository.dart';
import '../../chat/bloc/chat_repository.dart';
import 'package:backendless_sdk/backendless_sdk.dart';

import 'models/room.dart';

class BackendlessRepository
    implements ChatRepository, AuthenticationRepository {
  late final IDataStore<Map<dynamic, dynamic>> userStore;
  final userSubject = PublishSubject<User>();

  late final IDataStore<Map<dynamic, dynamic>> roomMessageStore;
  final roomMessageSubject = PublishSubject<List<RoomMessage>>();

  late final IDataStore<Map<dynamic, dynamic>> roomParticipantStore;
  final roomParticipantSubject = PublishSubject<List<RoomParticipant>>();

  late final IDataStore<Map<dynamic, dynamic>> roomStore;
  final roomSubject = PublishSubject<Room>();

  void Function()? _cleanUpRt;

  BackendlessRepository() {
    _initializeBackendless();
    _initializeStores();
  }

  void _initializeStores() {
    userStore = Backendless.data.of("user");
    roomMessageStore = Backendless.data.of("room_messages");
    roomParticipantStore = Backendless.data.of("room_participants");
    roomStore = Backendless.data.of("rooms");
  }

  void _initializeBackendless() {
    Backendless.setUrl("https://eu-api.backendless.com");
    Backendless.initApp(
      customDomain: "suavewall.backendless.app",
      jsApiKey: "31484F70-20C7-418E-9470-C9C1FF35DF3B",
      applicationId: "95B22E55-7B97-ED44-FFB3-46A479D95A00",
    );
  }

  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    final row = RoomMessage.fromDomain(message, chatRoomId);
    return roomMessageStore.create([row.toMap()]);
  }

  @override
  Stream<void> createSignOutStream() =>
      Stream.periodic(const Duration(milliseconds: 500))
          .asyncMap((event) => Backendless.userService.getCurrentUser())
          .where((event) => event != null);

  @override
  Future<List<ChatUser>> getAllUsers() async {
    final data = await userStore.find();
    return data!
        .map((e) => User.fromMap(e as Map<String, dynamic>))
        .map((e) => e.toDomain())
        .toList();
  }

  @override
  Future<InitialChatRoomState> getChatRoom(String chatRoomId) async {
    final childTableQuery = DataQueryBuilder()
      ..whereClause = "chatRoomId = '$chatRoomId'";

    final data = await Future.wait([
      roomStore.findById(chatRoomId),
      roomParticipantStore.find(childTableQuery),
      roomMessageStore.find(childTableQuery),
      getAllUsers(),
    ]);

    final roomData = Room.fromMap(data[0] as Map<String, dynamic>);
    final participants =
        RoomParticipant.fromMaps(data[1] as List<Map<String, dynamic>>);
    final messages =
        RoomMessage.fromMaps(data[2] as List<Map<String, dynamic>>);
    final allUsers = data[3] as List<ChatUser>;

    return InitialChatRoomState(
        messages: messages.map((e) => e.toDomain()).toList(),
        metadata: ChatRoomMetadata(
          chatRoomId: chatRoomId,
          name: roomData.name,
          participants: participants.map((e) => e.toDomain(allUsers)).toList(),
        ));
  }

  Stream<TEntity> createRealtimeStream<TEntity>(
    EventHandler<Map<dynamic, dynamic>> rt,
    TEntity Function(Map<String, dynamic>) mapper, {
    String? whereClause,
  }) {
    final sub = PublishSubject<TEntity>();

    rt.addUpdateListener(
      (response) {
        final entity = mapper(response as Map<String, dynamic>);
        sub.add(entity);
      },
      whereClause: whereClause,
    );

    return sub;
  }

  Stream<List<TEntity>> createPollingStream<TEntity>(
    IDataStore<Map<dynamic, dynamic>> store,
    Duration interval,
    List<TEntity> Function(List<Map<String, dynamic>>) mapper, {
    String? whereClause,
  }) {
    final queryBuilder = whereClause == null
        ? null
        : (DataQueryBuilder()..whereClause = whereClause);

    return Stream.periodic(interval)
        .asyncMap((event) => store.find(queryBuilder))
        .map((event) => mapper(event as List<Map<String, dynamic>>));
  }

  void cleanUpRealtime(
    EventHandler<Map<dynamic, dynamic>> rt,
  ) {
    rt.removeUpdateListeners();
  }

  @override
  Stream<InitialChatRoomState> getChatRoomStream(String chatRoomId) {
    if (_cleanUpRt != null) _cleanUpRt!();

    final roomRt = roomStore.rt();

    final roomUpdates = createRealtimeStream<Room>(
      roomRt,
      (input) => Room.fromMap(input),
    );

    final roomMessageUpdates = createPollingStream<RoomMessage>(
      roomMessageStore,
      const Duration(milliseconds: 500),
      (input) => RoomMessage.fromMaps(input),
    );
    final roomParticipantUpdates = createPollingStream<RoomParticipant>(
      roomParticipantStore,
      const Duration(milliseconds: 500),
      (input) => RoomParticipant.fromMaps(input),
    );

    _cleanUpRt = () {
      cleanUpRealtime(roomRt);
    };

    return CombineLatestStream(
      [roomUpdates, roomMessageUpdates, roomParticipantUpdates],
      (input) =>
          Quadruple<Room, List<RoomMessage>, List<RoomParticipant>, void>(
        t1: input[0] as Room,
        t2: input[1] as List<RoomMessage>,
        t3: input[2] as List<RoomParticipant>,
        t4: null,
      ),
    )
        .asyncMap(
          (event) async => Quadruple<Room, List<RoomMessage>,
              List<RoomParticipant>, List<ChatUser>>(
            t1: event.t1,
            t2: event.t2,
            t3: event.t3,
            t4: await getAllUsers(),
          ),
        )
        .map(
          (event) => InitialChatRoomState(
            messages: event.t2.map((e) => e.toDomain()).toList(),
            metadata: ChatRoomMetadata(
              chatRoomId: event.t1.roomId,
              name: event.t1.name,
              participants: event.t3.map((e) => e.toDomain(event.t4)).toList(),
            ),
          ),
        );
  }

  @override
  Stream<UserChangedEvent> getUserStream() =>
      Backendless.userService.getCurrentUser().asStream().switchMap((event) {
        final userId = event!.getUserId();

        final userUpdates = createPollingStream<User>(
                userStore, const Duration(milliseconds: 500), (rows) {
          final row = rows.single;
          return [User.fromMap(row)];
        }, whereClause: "userId = '$userId'")
            .map((event) => event.single);

        final participantUpdates = createPollingStream(
            roomParticipantStore,
            const Duration(milliseconds: 500),
            (rows) => RoomParticipant.fromMaps(rows),
            whereClause: "userId = '$userId'");

        final roomUpdates = createPollingStream(
          roomStore,
          const Duration(milliseconds: 500),
          (rows) => Room.fromMaps(rows),
        );

        return CombineLatestStream(
          [userUpdates, participantUpdates, roomUpdates],
          (values) => Quadruple<User, List<RoomParticipant>, List<Room>, void>(
            t1: values[0] as User,
            t2: values[1] as List<RoomParticipant>,
            t3: values[2] as List<Room>,
            t4: null,
          ),
        ).map((event) {
          final chatRoomOptions = event.t2
              .map((e) =>
                  event.t3.singleWhere((element) => element.roomId == e.roomId))
              .map((e) => ChatRoomOption(
                    isSelected: false,
                    chatRoomId: e.roomId,
                    name: e.name,
                  ))
              .toList();

          return UserChangedEvent(
            event.t1.toDomain(),
            chatRoomOptions,
          );
        });
      });

  @override
  Future<bool> isCurrentProfileCompleted() async {
    final currentUser = await Backendless.userService.getCurrentUser();
    final userId = currentUser!.getUserId();
    final query = DataQueryBuilder()..whereClause = "userId = '$userId'";

    final objectCount = await userStore.getObjectCount(query);

    return objectCount! > 0;
  }

  @override
  Future<void> setFullName(String fullName) async {
    final currentUser = await Backendless.userService.getCurrentUser();
    if (currentUser == null) return;

    final profile = User(currentUser.getUserId(), fullName);
    await userStore.update(profile.getWhereClause(), profile.toMap());
  }

  @override
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
      String username, String password) async {
    await Backendless.userService.login(username, password, true);
    return AuthentificationResult.success;
  }

  @override
  Future<void> signOut() {
    return Backendless.userService.logout();
  }

  @override
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
      String username, String password) async {
    final user = BackendlessUser()
      ..email = username
      ..password = password;

    await Backendless.userService.register(user);

    return AuthentificationResult.success;
  }

  @override
  Future<void> updateChatRoom(ChatRoomMetadata metadata) async {
    final participants = RoomParticipant.fromDomain(metadata);
    final room = Room.fromDomain(metadata);

    await Future.wait([
      roomStore.update(room.getWhereClause(), room.toMap()),
      roomParticipantStore.remove(whereClause: room.getWhereClause()),
    ]);

    final newParticipants = participants.map((e) => e.toMap()).toList();
    await roomParticipantStore.create(newParticipants);
  }
}
