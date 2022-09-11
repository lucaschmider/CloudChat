import 'package:appwrite/models.dart';
import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';
import 'package:cloud_chat/utils/date_time_extensions.dart';

class DatabaseMappers {
  static Map<String, dynamic> mapChatRoomMetadata(ChatRoomMetadata metadata) {
    return {
      "name": metadata.name,
      "participants": metadata.participants.map((p) => p.userId).toList(),
    };
  }

  static Map<String, String> mapMessage(ChatMessage message) {
    return {
      "userId": message.userId,
      "timestamp": message.timestamp.toIso8601String(),
      "text": message.text,
    };
  }

  static InitialChatRoomState parseInitialChatRoomState({
    required Map<String, dynamic> data,
    required String chatRoomId,
    required List<ChatUser> allUsers,
    required DocumentList messages,
  }) {
    final participants =
        (data["participants"] as List<dynamic>).map((e) => e as String);
    return InitialChatRoomState(
      messages:
          messages.documents.map((e) => parseChatMessage(e.data)).toList(),
      metadata: parseMetadata(
        chatRoomId,
        data,
        participants,
        allUsers,
      ),
    );
  }

  static ChatRoomMetadata parseMetadata(
      String chatRoomId,
      Map<String, dynamic> data,
      Iterable<String> participants,
      List<ChatUser> allUsers) {
    return ChatRoomMetadata(
      chatRoomId: chatRoomId,
      name: data["name"],
      participants: participants
          .map((e) => allUsers.singleWhere((element) => element.userId == e))
          .toList(),
    );
  }

  static ChatMessage parseChatMessage(Map<String, dynamic> data) {
    return ChatMessage(
      text: data["text"],
      userId: data["sender"],
      timestamp: Mappers.parseDate(data["timestamp"]),
    );
  }
}
