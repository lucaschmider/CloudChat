import 'package:flutter/material.dart';

@immutable
class ChatUser {
  final String userId;
  final String name;

  const ChatUser({
    required this.userId,
    required this.name,
  });

  static ChatUser fromDynamic(dynamic data) => ChatUser(
        userId: data["userId"],
        name: data["name"],
      );
}
