import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:flutter/material.dart';

@immutable
class UserChangedEvent {
  final ChatUser? user;
  final List<ChatRoomOption>? chatRoomOptions;

  const UserChangedEvent(this.user, this.chatRoomOptions);

  static UserChangedEvent fromDynamic(
          dynamic user, Map<String, dynamic> chatRooms) =>
      UserChangedEvent(
          ChatUser.fromDynamic(user),
          chatRooms.entries
              .map(
                (entry) =>
                    ChatRoomOption.fromDynamic(false, entry.key, entry.value),
              )
              .toList());
}
