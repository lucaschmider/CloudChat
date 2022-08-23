import 'package:cloud_chat/chat/views/chat_message_input.dart';
import 'package:cloud_chat/chat/views/chat_message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/models/chat_message.dart';

@immutable
class _RelevantBlocSubset {
  final List<ChatMessage> messages;
  final String ownUserId;

  const _RelevantBlocSubset({
    required this.messages,
    required this.ownUserId,
  });
}

class ChatRoomView extends StatelessWidget {
  const ChatRoomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocSelector<ChatBloc, ChatState, _RelevantBlocSubset>(
                  selector: (state) => _RelevantBlocSubset(
                      messages: state.messages,
                      ownUserId: state.sender!.userId),
                  builder: (context, state) => ListView.builder(
                    itemBuilder: (context, index) {
                      final message = state.messages.elementAt(index);
                      return ChatMessageView(
                        message: message,
                        isFromAnotherParticipant:
                            message.userId != state.ownUserId,
                      );
                    },
                    itemCount: state.messages.length,
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: ChatMessageInput(),
            )
          ],
        ),
      );
}
