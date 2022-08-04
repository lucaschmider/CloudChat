import 'package:cloud_chat/chat/views/chat_message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/models/chat_message.dart';

class ChatRoomView extends StatelessWidget {
  const ChatRoomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocSelector<ChatBloc, ChatState, List<ChatMessage>>(
            selector: (state) => state.messages,
            builder: (context, state) => ListView.builder(
              itemBuilder: (context, index) {
                final message = state.elementAt(index);
                return ChatMessageView(
                    message: message, isFromAnotherParticipant: false);
              },
              itemCount: state.length,
            ),
          ),
        ),
      );
}
