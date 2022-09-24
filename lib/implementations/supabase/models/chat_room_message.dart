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
        chatRoomId: data["chatRoomId"],
        createdAt: DateTime.parse(data["createdAt"]),
        messageId: data["messageId"],
        sender: data["sender"],
        text: data["text"],
      );
}
