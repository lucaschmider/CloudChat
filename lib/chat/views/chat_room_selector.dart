import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
import 'package:cloud_chat/views/custom_button.dart';
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
        child: Material(
          child: Column(
            children: [
              BlocSelector<ChatBloc, ChatState, List<ChatRoomOption>>(
                selector: (state) => state.chatRoomOptions,
                builder: (context, state) => ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final chatRoom = state.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 16.0,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        tileColor: chatRoom.isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.background,
                        title: Text(chatRoom.name),
                        onTap: () => context
                            .read<ChatBloc>()
                            .add(ChatRoomSelected(chatRoom.chatRoomId)),
                      ),
                    );
                  },
                  itemCount: state.length,
                ),
              ),
              CustomButton(
                  isPrimary: false,
                  text: "Raum erstellen",
                  onClick: () => context
                      .read<ChatBloc>()
                      .add(const ChatEditRequested(null))),
            ],
          ),
        ),
      );
}
