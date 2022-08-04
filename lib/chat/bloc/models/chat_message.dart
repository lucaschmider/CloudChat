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
}
