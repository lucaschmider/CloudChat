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
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseRepository implements ChatRepository, AuthenticationRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    final roomRef = _firestore.doc("rooms/$chatRoomId");
    return roomRef.update({
      "messages": FieldValue.arrayUnion([message.toMap()])
    });
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

  ChatMessage parseChatMessage(e) {
    return ChatMessage(
      text: e["text"],
      userId: e["userId"],
      timestamp: Mappers.parseDate(e["timestamp"]),
    );
  }

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
  Stream<UserChangedEvent> getUserStream() => _firestore
          .collection("rooms")
          .where("participants", arrayContains: _auth.currentUser!.uid)
          .snapshots()
          .asyncMap((event) async {
        final profile =
            await _firestore.doc("users/${_auth.currentUser!.uid}").get();

        final chatRoomOptions = event.docs.map(
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
          ChatUser(
            name: profile.data()!["name"],
            userId: profile.id,
          ),
          chatRoomOptions,
        );
      });

  @override
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
      String username, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: username, password: password);
      return AuthentificationResult.success;
    } on FirebaseAuthException catch (e) {
      return getAuthenticationResult(e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
    String username,
    String password,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: username,
        password: password,
      );

      return Future.value(AuthentificationResult.success);
    } on FirebaseAuthException catch (e) {
      return getAuthenticationResult(e.code);
    }
  }

  @override
  Stream<InitialChatRoomState> getChatRoomStream(String chatRoomId) =>
      _firestore.doc("rooms/$chatRoomId").snapshots().asyncMap((event) async {
        final data = event.data()!;
        return InitialChatRoomState(
          messages: (data["messages"] as List<dynamic>)
              .map(parseChatMessage)
              .toList(),
          metadata: await getChatRoomMetadata(chatRoomId, data),
        );
      });

  AuthentificationResult getAuthenticationResult(String code) {
    switch (code) {
      case "user-not-found":
        return AuthentificationResult.unkownUser;
      case "invalid-email":
        return AuthentificationResult.unkownUser;
      case "wrong-password":
        return AuthentificationResult.invalidPassword;
      default:
        return AuthentificationResult.unknownError;
    }
  }

  @override
  Future<bool> isCurrentProfileCompleted() async {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) return false;

    final doc = await _firestore.doc("users/$currentUserId").get();
    return doc.exists;
  }

  @override
  Future<void> setFullName(String fullName) {
    final currentUserId = _auth.currentUser!.uid;
    return _firestore.doc("users/$currentUserId").set({
      "name": fullName,
    });
  }

  @override
  Future<void> updateChatRoom(ChatRoomMetadata metadata) {
    return _firestore.doc("rooms/${metadata.chatRoomId}").set(
      {
        "name": metadata.name,
        "participants": [
          ...metadata.participants.map((e) => e.userId),
          _auth.currentUser!.uid
        ],
        "messages": [],
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<List<ChatUser>> getAllUsers() async {
    final userDocs = await _firestore.collection("users").get();
    return userDocs.docs
        .where((element) => element.id != _auth.currentUser?.uid)
        .map((e) => ChatUser(
              userId: e.id,
              name: e.data()["name"],
            ))
        .toList();
  }
}
