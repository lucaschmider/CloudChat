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

  static ChatRoomOption fromDynamic(
    bool isSelected,
    String chatRoomId,
    dynamic data,
  ) =>
      ChatRoomOption(
        isSelected: isSelected,
        chatRoomId: chatRoomId,
        name: data["name"],
      );
}
