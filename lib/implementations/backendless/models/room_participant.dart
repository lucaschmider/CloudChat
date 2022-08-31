import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';

class RoomParticipant {
  final String roomId;
  final String userId;

  RoomParticipant._(this.roomId, this.userId);

  static RoomParticipant fromMap(Map<String, dynamic> input) {
    return RoomParticipant._(
      input["roomId"],
      input["userId"],
    );
  }

  static List<RoomParticipant> fromDomain(ChatRoomMetadata metadata) {
    return metadata.participants
        .map((e) => RoomParticipant._(metadata.chatRoomId, e.userId))
        .toList();
  }

  static List<RoomParticipant> fromMaps(List<Map<String, dynamic>> inputs) =>
      inputs.map((e) => fromMap(e)).toList();

  Map<String, dynamic> toMap() {
    return {
      "roomId": roomId,
      "userId": userId,
    };
  }

  ChatUser toDomain(List<ChatUser> allUsers) {
    return allUsers.singleWhere((element) => element.userId == userId);
  }

  String getWhereClause() {
    return "roomId = '$roomId' AND userId = '$userId'";
  }
}
