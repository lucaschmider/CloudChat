import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/implementations/supabase/supabase_key.dart';

class ChatRoomParticipant {
  final String chatRoomId;
  final String userId;

  ChatRoomParticipant._({
    required this.chatRoomId,
    required this.userId,
  });

  static ChatRoomParticipant fromDynamic(dynamic data) => ChatRoomParticipant._(
        chatRoomId: data[SupabaseKey.chatRoomIdColumn],
        userId: data[SupabaseKey.userIdColumn],
      );

  static List<ChatRoomParticipant> fromDomain(ChatRoomMetadata model) =>
      model.participants
          .map((e) => ChatRoomParticipant._(
                chatRoomId: model.chatRoomId,
                userId: e.userId,
              ))
          .toList();
  Map<String, dynamic> toMap() => {
        SupabaseKey.chatRoomIdColumn: chatRoomId,
        SupabaseKey.userIdColumn: userId,
      };
}
