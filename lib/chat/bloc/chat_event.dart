part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {
  const ChatEvent();
}

@immutable
class ChatLogin extends ChatEvent {
  final ChatUser user;
  final List<ChatRoomOption> chatRoomOptions;
  const ChatLogin(this.user, this.chatRoomOptions);
}

class ChatLogout extends ChatEvent {}

class ChatRoomRetrieved extends ChatEvent {
  final ChatRoomMetadata chatRoom;
  final List<ChatMessage> messages;
  const ChatRoomRetrieved({
    required this.chatRoom,
    required this.messages,
  });
}

class ChatRoomSelected extends ChatEvent {
  final String chatRoomId;
  const ChatRoomSelected(this.chatRoomId);
}

class ChatMessageAdded extends ChatEvent {
  final ChatMessage message;
  const ChatMessageAdded(this.message);
}

class ChatRoomChanged extends ChatEvent {
  final ChatRoomMetadata chatRoom;
  const ChatRoomChanged(this.chatRoom);
}

class ChatTextSent extends ChatEvent {
  final String message;
  const ChatTextSent(this.message);
}
