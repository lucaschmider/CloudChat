import 'package:flutter/foundation.dart';
import 'chat_user.dart';

@immutable
class ChatRoomMetadata {
  final String name;
  final String chatRoomId;
  final List<ChatUser> participants;

  const ChatRoomMetadata({
    required this.name,
    required this.chatRoomId,
    required this.participants,
  });
}
