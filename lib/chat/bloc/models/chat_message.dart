import 'package:flutter/material.dart';

@immutable
class ChatMessage {
  final String userId;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        "userId": userId,
        "text": text,
        "timestamp": timestamp.toIso8601String(),
      };

  static ChatMessage fromDynamic(dynamic data) => ChatMessage(
        text: data["text"],
        userId: data["userId"],
        timestamp: data["timestamp"],
      );
}
