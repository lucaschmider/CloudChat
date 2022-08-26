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
    required super.sender,
    required super.chatRoom,
    required super.messages,
    required super.chatRoomOptions,
  });
}

@immutable
class ChatRoomEditMode extends ChatState {
  final List<ChatUser> allUsers;

  const ChatRoomEditMode({
    required super.sender,
    required super.chatRoom,
    required super.messages,
    required super.chatRoomOptions,
    required this.allUsers,
  });
}
