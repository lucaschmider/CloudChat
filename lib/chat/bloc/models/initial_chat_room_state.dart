import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:flutter/material.dart';

import 'chat_message.dart';

@immutable
class InitialChatRoomState {
  final ChatRoomMetadata metadata;
  final List<ChatMessage> messages;

  const InitialChatRoomState({
    required this.messages,
    required this.metadata,
  });
}
