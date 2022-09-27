import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:cloud_chat/implementations/supabase/supabase_key.dart';

class ChatRoom {
  final String chatRoomId;
  final String name;

  ChatRoom._({
    required this.chatRoomId,
    required this.name,
  });

  static ChatRoom fromDynamic(dynamic data) => ChatRoom._(
        chatRoomId: data[SupabaseKey.chatRoomIdColumn],
        name: data[SupabaseKey.roomNameColumn],
      );

  ChatRoomOption toDomain() => ChatRoomOption(
        isSelected: false,
        chatRoomId: chatRoomId,
        name: name,
      );

  static ChatRoom fromDomain(ChatRoomMetadata model) => ChatRoom._(
        chatRoomId: model.chatRoomId,
        name: model.name,
      );

  Map<String, dynamic> toMap() => {
        SupabaseKey.chatRoomIdColumn: chatRoomId,
        SupabaseKey.roomNameColumn: name,
      };
}
