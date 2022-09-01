import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:uuid/uuid.dart';

class RoomMessage {
  static const _uuid = Uuid();
  final String roomId;
  final String messageId;
  final String sender;
  final String text;
  final DateTime timestamp;

  RoomMessage._({
    required this.roomId,
    required this.messageId,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  static RoomMessage fromMap(Map<String, dynamic> input) {
    return RoomMessage._(
      roomId: input["roomId"],
      messageId: input["messageId"],
      sender: input["sender"],
      text: input["text"],
      timestamp: input["timestamp"],
    );
  }

  static List<RoomMessage> fromMaps(List<dynamic> inputs) =>
      inputs.map((e) => fromMap(e)).toList();

  static RoomMessage fromDomain(
    ChatMessage message,
    String roomId,
  ) {
    return RoomMessage._(
      roomId: roomId,
      messageId: _uuid.v4(),
      sender: message.userId,
      text: message.text,
      timestamp: message.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "roomId": roomId,
      "messageId": messageId,
      "sender": sender,
      "text": text,
      "timestamp": timestamp,
    };
  }

  ChatMessage toDomain() {
    return ChatMessage(text: text, userId: sender, timestamp: timestamp);
  }
}
