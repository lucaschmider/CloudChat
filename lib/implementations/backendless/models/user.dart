import 'package:cloud_chat/chat/bloc/models/chat_user.dart';

class User {
  final String userId;
  final String name;

  User(this.userId, this.name);

  static User fromMap(Map<String, dynamic> input) {
    return User(
      input["userId"],
      input["name"],
    );
  }

  static List<User> fromMaps(List<Map<String, dynamic>> inputs) =>
      inputs.map((e) => fromMap(e)).toList();

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "name": name,
    };
  }

  ChatUser toDomain() {
    return ChatUser(
      userId: userId,
      name: name,
    );
  }

  String getWhereClause() => "userId = '$userId'";
}
