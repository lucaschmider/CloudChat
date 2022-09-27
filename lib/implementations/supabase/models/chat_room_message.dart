import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:cloud_chat/implementations/supabase/supabase_key.dart';

import '../../../utils/uuid.dart';

class ChatRoomMessage {
  final String messageId;
  final String chatRoomId;
  final String text;
  final DateTime createdAt;
  final String sender;

  ChatRoomMessage._({
    required this.messageId,
    required this.chatRoomId,
    required this.text,
    required this.createdAt,
    required this.sender,
  });

  static ChatRoomMessage fromDynamic(dynamic data) => ChatRoomMessage._(
        chatRoomId: data[SupabaseKey.chatRoomIdColumn],
        createdAt: DateTime.parse(data[SupabaseKey.createdAtColumn]),
        messageId: data[SupabaseKey.messageIdColumn],
        sender: data[SupabaseKey.senderColumn],
        text: data[SupabaseKey.textColumn],
      );

  static ChatRoomMessage fromDomain(ChatMessage message, String chatRoomId) =>
      ChatRoomMessage._(
        messageId: uuid.v4(),
        chatRoomId: chatRoomId,
        text: message.text,
        createdAt: message.timestamp,
        sender: message.userId,
      );

  Map<String, dynamic> toMap() => {
        "messageid": messageId,
        "chatroomid": chatRoomId,
        "createdat": createdAt.toString(),
        "sender": sender,
        "text": text,
      };
  ChatMessage toDomain() => ChatMessage(
        text: text,
        userId: sender,
        timestamp: createdAt,
      );
}
