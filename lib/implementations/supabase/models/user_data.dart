import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/implementations/supabase/supabase_key.dart';

class UserData {
  final String userId;
  final String name;

  UserData._({
    required this.userId,
    required this.name,
  });

  static UserData fromDynamic(dynamic data) => UserData._(
        userId: data[SupabaseKey.userIdColumn],
        name: data[SupabaseKey.nameColumn],
      );

  static List<UserData> fromRows(List<dynamic> data) =>
      data.map((e) => UserData.fromDynamic(e)).toList();

  ChatUser toDomain() => ChatUser(
        userId: userId,
        name: name,
      );
}
