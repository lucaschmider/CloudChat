import 'package:flutter/foundation.dart';

@immutable
class ChatRoomOption {
  final bool isSelected;
  final String chatRoomId;
  final String name;

  const ChatRoomOption({
    required this.isSelected,
    required this.chatRoomId,
    required this.name,
  });
}
