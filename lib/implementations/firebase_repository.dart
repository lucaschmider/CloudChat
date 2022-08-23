import 'package:cloud_chat/bloc/authentification_repository.dart';
import 'package:cloud_chat/bloc/models/authentification_result.dart';
import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';
import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_extensions.dart';

class FirebaseRepository implements ChatRepository, AuthenticationRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    final roomRef = _firestore.doc("rooms/$chatRoomId");
    return roomRef.update({
      "messages": FieldValue.arrayUnion([message.toMap()])
    });
  }

  @override
  Stream<void> createSignOutStream() {
    return const Stream.empty();
  }

  @override
  Future<InitialChatRoomState> getChatRoom(String chatRoomId) async {
    final path = "rooms/$chatRoomId";
    final roomSnapshot = await _firestore.doc(path).get();

    final data = roomSnapshot.data()!;
    final metadata = await getChatRoomMetadata(
      chatRoomId,
      data,
    );

    final messages =
        (data["messages"] as List<dynamic>).map(parseChatMessage).toList();

    return InitialChatRoomState(
      messages: messages,
      metadata: metadata,
    );
  }

  ChatMessage parseChatMessage(e) => ChatMessage(
        text: e["text"],
        userId: e["userId"],
        timestamp: Mappers.parseDate(e["timestamp"]),
      );

  Future<ChatRoomMetadata> getChatRoomMetadata(
      String chatRoomId, dynamic data) async {
    final participantIds = (data["participants"] as List<dynamic>)
        .map((e) => e as String)
        .toList();

    final participantSnapshots = await _firestore
        .collection("users")
        .where(
          FieldPath.documentId,
          whereIn: participantIds,
        )
        .get();

    final participants = participantSnapshots.docs.map((e) {
      final d = e.data();
      return ChatUser(userId: e.id, name: d["name"]);
    }).toList();

    return ChatRoomMetadata(
      name: data["name"],
      chatRoomId: chatRoomId,
      participants: participants,
    );
  }

  @override
  Stream<ChatMessage> getMessageStream(String chatRoomId) => _firestore
      .doc("rooms/$chatRoomId")
      .snapshots()
      .map((event) => parseChatMessage(event.data()));

  @override
  Stream<ChatRoomMetadata> getMetadataStream(String chatRoomId) => _firestore
      .doc("rooms/$chatRoomId")
      .snapshots()
      .asyncMap((event) => getChatRoomMetadata(chatRoomId, event.data()));

  @override
  Stream<UserChangedEvent> getUserStream() =>
      Stream.value("EmfC8HLMScfXu0pau5qCvTCJFc73").asyncMap((event) async {
        final results = await Future.wait([
          _firestore.doc("users/$event").get(),
          _firestore
              .collection("rooms")
              .where("participants", arrayContains: event)
              .get(),
        ]);

        final currentUserSnapshot =
            results[0] as DocumentSnapshot<Map<String, dynamic>>;
        final chatRooms = results[1] as QuerySnapshot<Map<String, dynamic>>;

        var currentUserData = currentUserSnapshot.data()!;

        final chatUser = ChatUser(
          userId: currentUserSnapshot.id,
          name: currentUserData["name"],
        );

        final chatRoomOptions = chatRooms.docs.map(
          (e) {
            final data = e.data();
            return ChatRoomOption(
              isSelected: false,
              chatRoomId: e.id,
              name: data["name"],
            );
          },
        ).toList();

        return UserChangedEvent(
          chatUser,
          chatRoomOptions,
        );
      });

  @override
  Future<AuthentificationResult> signInWithGoogleAsync() {
    return Future.value(AuthentificationResult.success);
  }

  @override
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
      String username, String password) {
    return Future.value(AuthentificationResult.success);
  }

  @override
  Future<void> signOut() {
    return Future.value();
  }

  @override
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
      String username, String email, String fullName) {
    return Future.value(AuthentificationResult.success);
  }
}
