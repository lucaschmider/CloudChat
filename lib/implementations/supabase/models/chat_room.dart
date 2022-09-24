class ChatRoom {
  final String chatRoomId;
  final String name;

  ChatRoom._({
    required this.chatRoomId,
    required this.name,
  });

  static fromDynamic(dynamic data) => ChatRoom._(
        chatRoomId: data["chatRoomId"],
        name: data["name"],
      );
}
