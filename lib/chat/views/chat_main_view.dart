import 'package:cloud_chat/chat/views/chat_room_selector.dart';
import 'package:cloud_chat/chat/views/chat_room_view.dart';
import 'package:flutter/material.dart';

class ChatMainView extends StatelessWidget {
  const ChatMainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Row(
          children: const [
            Expanded(
              flex: 1,
              child: ChatRoomSelector(),
            ),
            Expanded(
              flex: 3,
              child: ChatRoomView(),
            )
          ],
        ),
      );
}
