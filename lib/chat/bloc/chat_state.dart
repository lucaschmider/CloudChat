part of 'chat_bloc.dart';

@immutable
abstract class ChatState {
  final ChatUser? sender;
  final ChatRoomMetadata? chatRoom;
  final List<ChatMessage> messages;

  const ChatState({
    required this.sender,
    required this.chatRoom,
    required this.messages,
  });
}

@immutable
class ChatInitial extends ChatState {
  const ChatInitial()
      : super(
          chatRoom: null,
          sender: null,
          messages: const [],
        );
}

@immutable
class ChatUserAvailable extends ChatState {
  const ChatUserAvailable({required ChatUser sender})
      : super(
          chatRoom: null,
          sender: sender,
          messages: const [],
        );
}

@immutable
class ChatRoomAvailable extends ChatState {
  const ChatRoomAvailable({
    required ChatUser sender,
    required ChatRoomMetadata chatRoom,
    required List<ChatMessage> messages,
  }) : super(
          chatRoom: chatRoom,
          sender: sender,
          messages: messages,
        );
}
