import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';

import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';

import 'package:cloud_chat/chat/bloc/models/chat_user.dart';

import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';

import 'package:cloud_chat/chat/bloc/models/chat_message.dart';

import 'package:cloud_chat/bloc/models/authentification_result.dart';

import '../bloc/authentification_repository.dart';
import '../chat/bloc/chat_repository.dart';
import 'package:backendless_sdk/backendless_sdk.dart';

class BackendlessRepository
    implements ChatRepository, AuthenticationRepository {
  BackendlessRepository() {
    Backendless.setUrl("https://eu-api.backendless.com");
    Backendless.initApp(
      customDomain: "suavewall.backendless.app",
      jsApiKey: "31484F70-20C7-418E-9470-C9C1FF35DF3B",
      applicationId: "95B22E55-7B97-ED44-FFB3-46A479D95A00",
    );
  }
  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    return Backendless.data.of("room_messages").create([
      {
        "chatRoomId": chatRoomId,
        "senderId": message.userId,
        "timestamp": message.timestamp,
        "text": message.text,
      }
    ]);
  }

  @override
  Stream<void> createSignOutStream() =>
      Stream.periodic(const Duration(milliseconds: 500))
          .asyncMap((event) => Backendless.userService.getCurrentUser())
          .where((event) => event != null);

  @override
  Future<List<ChatUser>> getAllUsers() async {
    final data = await Backendless.data.of("users").find();
    return data!
        .map(
          (e) => ChatUser(
            userId: e!["userId"],
            name: e["name"],
          ),
        )
        .toList();
  }

  @override
  Future<InitialChatRoomState> getChatRoom(String chatRoomId) async {
    final childTableQuery = DataQueryBuilder()
      ..whereClause = "chatRoomId = '$chatRoomId'";

    final data = await Future.wait([
      Backendless.data.of("rooms").findById("chatRoomId"),
      Backendless.data.of("room_participants").find(childTableQuery),
      Backendless.data.of("room_messages").find(childTableQuery),
      getAllUsers(),
    ]);

    final roomData = data[0] as Map<String, dynamic>;
    final participants = data[1] as List<Map<String, dynamic>>;
    final messages = data[2] as List<Map<String, dynamic>>;
    final allUsers = data[3] as List<ChatUser>;

    return InitialChatRoomState(
        messages: messages
            .map((e) => ChatMessage(
                  text: e["text"],
                  userId: e["senderId"],
                  timestamp: DateTime.parse(e["timestamp"]),
                ))
            .toList(),
        metadata: ChatRoomMetadata(
          chatRoomId: chatRoomId,
          name: roomData["name"],
          participants: participants
              .map((e) => allUsers.singleWhere(
                  (element) => e["participantId"] == element.userId))
              .toList(),
        ));
  }

  @override
  Stream<InitialChatRoomState> getChatRoomStream(String chatRoomId) {
    final rt = Backendless.data.of("rooms").rt();
    rt.addUpdateListener((response) {});
    Stream.
  }

  @override
  Stream<UserChangedEvent> getUserStream();

  @override
  Future<bool> isCurrentProfileCompleted() {
    // TODO: implement isCurrentProfileCompleted
    throw UnimplementedError();
  }

  @override
  Future<void> setFullName(String fullName) {
    // TODO: implement setFullName
    throw UnimplementedError();
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
  Future<void> updateChatRoom(ChatRoomMetadata metadata) {
    // TODO: implement updateChatRoom
    throw UnimplementedError();
  }
}
