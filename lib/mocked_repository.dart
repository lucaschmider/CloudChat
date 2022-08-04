import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/bloc/models/initial_chat_room_state.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_message.dart';

class MockedRepository implements ChatRepository {
  @override
  Future<void> createMessage(String chatRoomId, ChatMessage message) {
    // TODO: implement createMessage
    throw UnimplementedError();
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
  Stream<ChatMessage> getMessageStream(String chatRoomId) {
    return Stream.periodic(
      const Duration(seconds: 10),
      (counter) => ChatMessage(
        text: "Lorem Ipsum",
        userId: "b2e88437-a8fc-4447-91fb-784b6c3c1265",
        timestamp: DateTime.now(),
      ),
    );
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
  Stream<ChatUser?> getUserStream() async* {
    yield null;

    await Future.delayed(const Duration(seconds: 3));
    yield const ChatUser(
      userId: "3e2d2fa3-be75-471e-99b4-8163b2ac334d",
      name: "Max Mustermann",
    );
  }
}
