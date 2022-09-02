import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';

import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';

import 'package:cloud_chat/chat/bloc/models/chat_user.dart';

import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';

import 'package:cloud_chat/chat/bloc/models/chat_message.dart';

import 'package:cloud_chat/bloc/models/authentification_result.dart';
import 'package:uuid/uuid.dart';

import '../../bloc/authentification_repository.dart';
import '../../chat/bloc/chat_repository.dart';

class AppwriteRepository implements ChatRepository, AuthenticationRepository {
  final _client = Client();
  late final _auth = Account(_client);

  AppwriteRepository() {
    _client
        .setEndpoint('https://13.73.148.57/v1')
        .setProject('630cb8e5d2403e179f24')
        .setSelfSigned(status: false);
  }

  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    // TODO: implement createMessage
    throw UnimplementedError();
  }

  @override
  Stream<void> createSignOutStream() => Stream.empty();

  @override
  Future<List<ChatUser>> getAllUsers() {
    // TODO: implement getAllUsers
    throw UnimplementedError();
  }

  @override
  Future<InitialChatRoomState> getChatRoom(String chatRoomId) {
    // TODO: implement getChatRoom
    throw UnimplementedError();
  }

  @override
  Stream<InitialChatRoomState> getChatRoomStream(String chatRoomId) {
    // TODO: implement getChatRoomStream
    throw UnimplementedError();
  }

  @override
  Stream<UserChangedEvent> getUserStream() {
    // TODO: implement getUserStream
    throw UnimplementedError();
  }

  @override
  Future<bool> isCurrentProfileCompleted() => Future.value(false);

  @override
  Future<void> setFullName(String fullName) {
    // TODO: implement setFullName
    throw UnimplementedError();
  }

  @override
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
      String username, String password) async {
    try {
      final session =
          await _auth.createEmailSession(email: username, password: password);
      print("Success: $session");
      return AuthentificationResult.success;
    } catch (e) {
      print(e.toString());
      return AuthentificationResult.unknownError;
    }
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
      String username, String password) async {
    try {
      final user = await _auth.create(
        userId: const Uuid().v4(),
        email: username,
        password: password,
      );
      print("Success: $user");
      return AuthentificationResult.success;
    } catch (e) {
      print(e.toString());
      return AuthentificationResult.unknownError;
    }
  }

  @override
  Future<void> updateChatRoom(ChatRoomMetadata metadata) {
    // TODO: implement updateChatRoom
    throw UnimplementedError();
  }
}
