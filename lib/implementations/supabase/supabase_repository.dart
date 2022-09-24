import 'package:cloud_chat/bloc/authentification_repository.dart';
import 'package:cloud_chat/bloc/models/authentification_result.dart';
import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';
import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_message.dart';

class SupabaseRepository implements AuthenticationRepository, ChatRepository {
  static SupabaseRepository? _instance;

  static SupabaseRepository getInstance() {
    _instance ??= SupabaseRepository();
    return _instance!;
  }

  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    // TODO: implement createMessage
    throw UnimplementedError();
  }

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
      String username, String password) {
    // TODO: implement signInWithUsernameAndPasswordAsync
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
      String username, String password) {
    // TODO: implement signUpWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<void> updateChatRoom(ChatRoomMetadata metadata) {
    // TODO: implement updateChatRoom
    throw UnimplementedError();
  }
}
