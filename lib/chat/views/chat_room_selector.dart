import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';

class ChatRoomSelector extends StatelessWidget {
  const ChatRoomSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary,
              blurRadius: 6.0,
            ),
          ],
        ),
        child: BlocSelector<ChatBloc, ChatState, List<ChatRoomOption>>(
          selector: (state) => state.chatRoomOptions,
          builder: (context, state) => ListView.builder(
            itemBuilder: (context, index) {
              final chatRoom = state.elementAt(index);
              return Material(
                color: chatRoom.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                child: InkWell(
                  onTap: () => context
                      .read<ChatBloc>()
                      .add(ChatRoomSelected(chatRoom.chatRoomId)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 20.0,
                    ),
                    child: Text(
                      chatRoom.name,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: chatRoom.isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSecondary,
                            fontWeight: chatRoom.isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                ),
              );
            },
            itemCount: state.length,
          ),
        ),
      );
}
