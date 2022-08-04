part of 'chat_bloc.dart';

@immutable
abstract class ChatState {
  final ChatUser? sender;
  final ChatRoomMetadata? chatRoom;
  final List<ChatMessage> messages;
  final List<ChatRoomOption> chatRoomOptions;

  const ChatState({
    required this.sender,
    required this.chatRoom,
    required this.messages,
    required this.chatRoomOptions,
  });
}

@immutable
class ChatInitial extends ChatState {
  const ChatInitial()
      : super(
          chatRoom: null,
          sender: null,
          messages: const [],
          chatRoomOptions: const [],
        );
}

@immutable
class ChatUserAvailable extends ChatState {
  const ChatUserAvailable({
    required ChatUser sender,
    required List<ChatRoomOption> chatRoomOptions,
  }) : super(
          chatRoom: null,
          sender: sender,
          messages: const [],
          chatRoomOptions: chatRoomOptions,
        );
}

@immutable
class ChatRoomAvailable extends ChatState {
  const ChatRoomAvailable({
    required ChatUser sender,
    required ChatRoomMetadata chatRoom,
    required List<ChatMessage> messages,
    required List<ChatRoomOption> chatRoomOptions,
  }) : super(
          chatRoom: chatRoom,
          sender: sender,
          messages: messages,
          chatRoomOptions: chatRoomOptions,
        );
}
