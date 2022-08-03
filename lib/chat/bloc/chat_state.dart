part of 'chat_bloc.dart';

@immutable
abstract class ChatState {
  final String? currentUserId;
  final List<User> registeredUsers;
  final List<Message> messages;

  const ChatState({
    required this.messages,
    required this.currentUserId,
    required this.registeredUsers,
  });
}

class ChatInitial extends ChatState {
  const ChatInitial()
      : super(
          currentUserId: null,
          messages: const [],
          registeredUsers: const [],
        );
}

class ChatLoading extends ChatState {
  const ChatLoading({
    required List<User> registeredUsers,
    required String currentUserId,
  }) : super(
          currentUserId: currentUserId,
          messages: const [],
          registeredUsers: registeredUsers,
        );
}

class ChatAvailable extends ChatState {
  const ChatAvailable({
    required List<User> registeredUsers,
    required String currentUserId,
    required List<Message> messages,
  }) : super(
          currentUserId: currentUserId,
          messages: messages,
          registeredUsers: registeredUsers,
        );
}
