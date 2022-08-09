import 'package:cloud_chat/bloc/authentification_repository.dart';
import 'package:cloud_chat/bloc/backend_connector_repository.dart';
import 'package:cloud_chat/bloc/models/authentification_result.dart';
import 'package:cloud_chat/bloc/models/backend_connector.dart';
import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:cloud_chat/chat/bloc/models/user_changed_event.dart';

class MockedRepository implements ChatRepository, AuthenticationRepository {
  final outboundBuffer = <ChatMessage>[];
  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    outboundBuffer.add(message);
    return Future.value();
  }

  @override
  Future<InitialChatRoomState> getChatRoom(String chatRoomId) {
    return Future.value(
      InitialChatRoomState(
        messages: [
          ChatMessage(
            text: "Lorem Ipsum",
            userId: "b2e88437-a8fc-4447-91fb-784b6c3c1265",
            timestamp: DateTime.now(),
          )
        ],
        metadata: const ChatRoomMetadata(
          chatRoomId: "daca8b66-803a-4017-ae7e-853c2f8ffb04",
          name: "Globaler Chat",
          participants: [
            ChatUser(
              userId: "b2e88437-a8fc-4447-91fb-784b6c3c1265",
              name: "Martina Musterfrau",
            ),
            ChatUser(
              userId: "3e2d2fa3-be75-471e-99b4-8163b2ac334d",
              name: "Max Mustermann",
            ),
          ],
        ),
      ),
    );
  }

  @override
  Stream<ChatMessage> getMessageStream(String chatRoomId) async* {
    while (true) {
      while (outboundBuffer.isNotEmpty) {
        final message = outboundBuffer.removeAt(0);
        yield message;
      }

      yield ChatMessage(
        text: "Mocked",
        userId: "b2e88437-a8fc-4447-91fb-784b6c3c1265",
        timestamp: DateTime.now(),
      );

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Stream<ChatRoomMetadata> getMetadataStream(String chatRoomId) async* {
    yield const ChatRoomMetadata(
      chatRoomId: "daca8b66-803a-4017-ae7e-853c2f8ffb04",
      name: "Globaler Chat",
      participants: [
        ChatUser(
          userId: "b2e88437-a8fc-4447-91fb-784b6c3c1265",
          name: "Martina Musterfrau",
        ),
        ChatUser(
          userId: "3e2d2fa3-be75-471e-99b4-8163b2ac334d",
          name: "Max Mustermann",
        ),
      ],
    );
  }

  @override
  Stream<UserChangedEvent> getUserStream() async* {
    yield const UserChangedEvent(null, null);

    await Future.delayed(const Duration(microseconds: 3));
    yield const UserChangedEvent(
        ChatUser(
          userId: "3e2d2fa3-be75-471e-99b4-8163b2ac334d",
          name: "Max Mustermann",
        ),
        [
          ChatRoomOption(
              isSelected: false,
              chatRoomId: "6ab3b017-c7fe-42f0-a5e3-97951cdf39f6",
              name: "Lörrach"),
          ChatRoomOption(
              isSelected: false,
              chatRoomId: "fa23a2fb-edf5-407b-9061-c93ae4834fcc",
              name: "VEGA Global"),
          ChatRoomOption(
              isSelected: false,
              chatRoomId: "bc790e68-b5d0-4c3c-914f-8ec1730a49e0",
              name: "Neue Konzepte"),
          ChatRoomOption(
              isSelected: false,
              chatRoomId: "56ac6157-d74d-4d8c-9e59-81c937898cb6",
              name: "Felix Sommerer"),
        ]);
  }

  @override
  Stream<void> createSignOutStream() {
    return const Stream.empty();
  }

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
