import 'package:cloud_chat/chat/bloc/models/chat_user.dart';

class GetAllUsersResponse {
  final List<ChatUser> allUsers;

  GetAllUsersResponse._(this.allUsers);

  static GetAllUsersResponse fromMap(dynamic data) {
    final allUsers = data["allUsers"] as List<dynamic>;
    return GetAllUsersResponse._(allUsers.map(ChatUser.fromDynamic).toList());
  }
}
