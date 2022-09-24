class ChatRoomParticipant {
  final String chatRoomId;
  final String userId;

  ChatRoomParticipant._({
    required this.chatRoomId,
    required this.userId,
  });

  static ChatRoomParticipant fromDynamic(dynamic data) => ChatRoomParticipant._(
        chatRoomId: data["chatRoomId"],
        userId: data["userId"],
      );
}
