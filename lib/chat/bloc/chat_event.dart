part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {
  const ChatEvent();
}

@immutable
class ChatLogin extends ChatEvent {
  final ChatUser user;
  final List<ChatRoomOption> chatRoomOptions;
  const ChatLogin({
    required this.user,
    required this.chatRoomOptions,
  });
}

class ChatUserChanged extends ChatEvent {
  final ChatUser? user;
  final List<ChatRoomOption>? chatRoomOptions;

  const ChatUserChanged({
    required this.user,
    required this.chatRoomOptions,
  });
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

class ChatRoomChanged extends ChatEvent {
  final ChatRoomMetadata chatRoom;
  const ChatRoomChanged(this.chatRoom);
}

class ChatTextSent extends ChatEvent {
  final String message;
  const ChatTextSent(this.message);
}

class ChatEditRequested extends ChatEvent {
  final ChatRoomMetadata? metadata;

  const ChatEditRequested(this.metadata);
}

class ChatEditCompleted extends ChatEvent {
  final ChatRoomMetadata? metadata;

  const ChatEditCompleted(this.metadata);
}

class ChatAllUsersRetrieved extends ChatEvent {
  final List<ChatUser> allUsers;
  const ChatAllUsersRetrieved(this.allUsers);
}
