import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:flutter/material.dart';

@immutable
class ChatUser {
  final String userId;
  final String name;

  const ChatUser({
    required this.userId,
    required this.name,
  });
}
