import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';

class Room {
  final String roomId;
  final String name;

  Room._(this.roomId, this.name);

  static Room fromMap(Map<String, dynamic> input) {
    return Room._(
      input["roomId"],
      input["name"],
    );
  }

  static Room fromDomain(ChatRoomMetadata metadata) {
    return Room._(metadata.chatRoomId, metadata.name);
  }

  Map<String, dynamic> toMap() {
    return {
      "roomId": roomId,
      "name": name,
    };
  }

  static List<Room> fromMaps(List<Map<String, dynamic>> input) =>
      input.map((e) => Room.fromMap(e)).toList();

  String getWhereClause() {
    return "roomId = '$roomId'";
  }
}
