import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';

abstract class ChatRepository {
  Future<InitialChatRoomState> getChatRoom(String chatRoomId);
  Future<void> createMessage(String chatRoomId, ChatMessage message);

  Stream<ChatMessage> getMessageStream(String chatRoomId);
  Stream<ChatRoomMetadata> getMetadataStream(String chatRoomId);
  Stream<UserChangedEvent> getUserStream();
}
