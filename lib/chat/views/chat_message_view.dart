import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatMessageView extends StatelessWidget {
  final ChatMessage message;
  final bool isFromAnotherParticipant;

  const ChatMessageView({
    Key? key,
    required this.message,
    required this.isFromAnotherParticipant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: isFromAnotherParticipant
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFromAnotherParticipant) _buildAvatar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isFromAnotherParticipant
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: isFromAnotherParticipant
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                        ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isFromAnotherParticipant
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ),
            ),
          ),
          if (!isFromAnotherParticipant) _buildAvatar(),
        ],
      );

  CircleAvatar _buildAvatar() {
    return const CircleAvatar(
      child: Icon(Icons.person),
    );
  }
}
