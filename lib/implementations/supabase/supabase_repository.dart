import 'package:cloud_chat/bloc/authentification_repository.dart';
import 'package:cloud_chat/bloc/models/authentification_result.dart';
import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';
import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:cloud_chat/implementations/supabase/models/chat_room_message.dart';
import 'package:cloud_chat/implementations/supabase/models/chat_room_participant.dart';
import 'package:cloud_chat/implementations/supabase/models/user_data.dart';
import 'package:cloud_chat/implementations/supabase/supabase_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tuple/tuple.dart';

import 'models/chat_room.dart';

class SupabaseRepository implements AuthenticationRepository, ChatRepository {
  static SupabaseRepository? _instance;

  final SupabaseClient _supabase;

  SupabaseRepository._(
    this._supabase,
  );

  static Future<SupabaseRepository> getInstance() async {
    if (_instance == null) {
      final supabase = await Supabase.initialize(
        url: 'https://qycmljjbwxnuirgwqxyu.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5Y21sampid3hudWlyZ3dxeHl1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjM5MzU2ODMsImV4cCI6MTk3OTUxMTY4M30.nlsQLp5eU0acYGM_cPcGh_fKly45enAlocNwnWwFsUU',
      );
      _instance = SupabaseRepository._(supabase.client);
    }

    return _instance!;
  }

  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    final row = ChatRoomMessage.fromDomain(message, chatRoomId);
    return _supabase
        .from(SupabaseKey.messageTable)
        .insert(
          row.toMap(),
          returning: ReturningOption.minimal,
        )
        .execute();
  }

  @override
  Future<List<ChatUser>> getAllUsers() async {
    final userData =
        await _supabase.from(SupabaseKey.userTable).select().execute();

    return (userData.data as List<dynamic>)
        .map((e) => UserData.fromDynamic(e))
        .map((e) => e.toDomain())
        .toList();
  }

  Future<
      Tuple4<List<ChatRoomMessage>, ChatRoom, List<ChatRoomParticipant>,
          List<ChatUser>>> _getChatRoomData(String chatRoomId) async {
    final messages = _supabase
        .from(SupabaseKey.messageTable)
        .select()
        .eq(SupabaseKey.chatRoomIdColumn, chatRoomId)
        .execute();
    final room = _supabase
        .from(SupabaseKey.roomTable)
        .select()
        .eq(SupabaseKey.chatRoomIdColumn, chatRoomId)
        .single()
        .execute();
    final participants = _supabase
        .from(SupabaseKey.chatRoomParticipantTable)
        .select()
        .eq(SupabaseKey.chatRoomIdColumn, chatRoomId)
        .execute();
    final allUsers = getAllUsers();

    final data = await Future.wait([messages, room, participants, allUsers]);

    return Tuple4(
      ((data[0] as PostgrestResponse<dynamic>).data as List<dynamic>)
          .map((e) => ChatRoomMessage.fromDynamic(e))
          .toList(),
      (ChatRoom.fromDynamic((data[1] as PostgrestResponse<dynamic>).data)),
      ((data[2] as PostgrestResponse<dynamic>).data as List<dynamic>)
          .map((e) => ChatRoomParticipant.fromDynamic(e))
          .toList(),
      data[3] as List<ChatUser>,
    );
  }

  @override
  Future<InitialChatRoomState> getChatRoom(String chatRoomId) async {
    final data = await _getChatRoomData(chatRoomId);

    return InitialChatRoomState(
      messages: data.item1.map((e) => e.toDomain()).toList(),
      metadata: ChatRoomMetadata(
        chatRoomId: chatRoomId,
        name: data.item2.name,
        participants: data.item3
            .map((e) =>
                data.item4.singleWhere((element) => element.userId == e.userId))
            .toList(),
      ),
    );
  }

  @override
  Stream<InitialChatRoomState> getChatRoomStream(String chatRoomId) =>
      Stream.periodic(const Duration(milliseconds: 500))
          .asyncMap((event) => getChatRoom(chatRoomId));

  @override
  Stream<UserChangedEvent> getUserStream() =>
      Stream.periodic(const Duration(milliseconds: 500))
          .asyncMap((event) async {
        final currentUser = _supabase.auth.user();

        if (currentUser == null) {
          return const UserChangedEvent(null, null);
        }

        final data = await Future.wait([
          _supabase
              .from(SupabaseKey.userTable)
              .select()
              .eq(SupabaseKey.userIdColumn, currentUser.id)
              .single()
              .execute(),
          _supabase
              .from(SupabaseKey.chatRoomParticipantTable)
              .select()
              .eq(SupabaseKey.userIdColumn, currentUser.id)
              .execute(),
          _supabase.from(SupabaseKey.roomTable).select().execute(),
        ]);

        final profile = UserData.fromDynamic(data[0].data);
        final myRooms = (data[1].data as List<dynamic>)
            .map((e) => ChatRoomParticipant.fromDynamic(e))
            .toList();
        final allRooms = (data[2].data as List<dynamic>)
            .map((e) => ChatRoom.fromDynamic(e))
            .toList();

        return UserChangedEvent(
          profile.toDomain(),
          myRooms
              .map((e) => allRooms
                  .singleWhere((element) => element.chatRoomId == e.chatRoomId))
              .map((e) => e.toDomain())
              .toList(),
        );
      });

  @override
  Future<bool> isCurrentProfileCompleted() async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null) {
      return false;
    }

    final data = await _supabase
        .from(SupabaseKey.userTable)
        .select()
        .eq(SupabaseKey.userIdColumn, currentUser.id)
        .execute();

    return (data.data as List<dynamic>).isNotEmpty;
  }

  @override
  Future<void> setFullName(String fullName) async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null) {
      return;
    }

    await _supabase.from(SupabaseKey.userTable).upsert({
      SupabaseKey.userIdColumn: currentUser.id,
      SupabaseKey.nameColumn: fullName,
    }).execute();
  }

  @override
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
      String username, String password) async {
    final data = await _supabase.auth.signIn(
      email: username,
      password: password,
    );

    if (data.error == null) return AuthentificationResult.success;

    return AuthentificationResult.unknownError;
  }

  @override
  Future<void> signOut() => _supabase.auth.signOut();

  @override
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
      String username, String password) async {
    final data = await _supabase.auth.signUp(
      username,
      password,
    );

    if (data.error == null) return AuthentificationResult.success;

    return AuthentificationResult.unknownError;
  }

  @override
  Future<void> updateChatRoom(ChatRoomMetadata metadata) async {
    final roomRow = ChatRoom.fromDomain(metadata);
    final participantRows = ChatRoomParticipant.fromDomain(metadata);

    await _supabase
        .from(SupabaseKey.roomTable)
        .upsert(roomRow.toMap())
        .execute();
    await _supabase
        .from(SupabaseKey.chatRoomParticipantTable)
        .delete()
        .eq(SupabaseKey.chatRoomIdColumn, metadata.chatRoomId)
        .execute();
    await _supabase
        .from(SupabaseKey.chatRoomParticipantTable)
        .insert(participantRows.map((e) => e.toMap()).toList())
        .execute();
  }
}
