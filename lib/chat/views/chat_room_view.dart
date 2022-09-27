import 'package:cloud_chat/chat/bloc/models/chat_room_metadata.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/views/chat_message_input.dart';
import 'package:cloud_chat/chat/views/chat_message_view.dart';
import 'package:cloud_chat/views/custom_button.dart';
import 'package:cloud_chat/views/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../bloc/chat_bloc.dart';

class ChatRoomView extends StatelessWidget {
  const ChatRoomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.background,
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatRoomEditMode) {
              return _ChatRoomEditor(
                currentMetadata: state.chatRoom,
                allUsers: state.allUsers,
                ownUserId: state.sender!.userId,
              );
            }
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: CustomButton(
                    isPrimary: false,
                    text: "Raum bearbeiten",
                    onClick: () => context.read<ChatBloc>().add(
                          ChatEditRequested(state.chatRoom),
                        ),
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final message = state.messages.elementAt(index);
                          return ChatMessageView(
                            message: message,
                            isFromAnotherParticipant:
                                message.userId != state.sender!.userId,
                          );
                        },
                        itemCount: state.messages.length,
                      )),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: ChatMessageInput(),
                )
              ],
            );
          },
        ),
      );
}

class _ChatRoomEditor extends StatefulWidget {
  final uuid = const Uuid();
  final List<ChatUser> allUsers;
  final ChatRoomMetadata? currentMetadata;
  final String ownUserId;

  const _ChatRoomEditor({
    Key? key,
    required this.currentMetadata,
    required this.allUsers,
    required this.ownUserId,
  }) : super(key: key);

  @override
  State<_ChatRoomEditor> createState() => _ChatRoomEditorState();
}

class _ChatRoomEditorState extends State<_ChatRoomEditor> {
  final nameController = TextEditingController();
  var participants = <ChatUser, bool>{};

  @override
  void initState() {
    if (widget.currentMetadata != null) {
      nameController.text = widget.currentMetadata!.name;
    }
    participants = widget.allUsers.fold(
      <ChatUser, bool>{},
      (accumulator, element) => {
        ...accumulator,
        element: (element.userId == widget.ownUserId) ||
            (widget.currentMetadata != null &&
                widget.currentMetadata!.participants
                    .any((p) => p.userId == element.userId))
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: CustomTextInput(
              controller: nameController,
              hintText: "Name",
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: ((context, index) {
              final participant = participants.entries.elementAt(index);

              if (participant.key.userId == "") {
                return Container();
              }

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(participant.key.name),
                trailing: Checkbox(
                  onChanged: (value) =>
                      setState(() => participants[participant.key] = value!),
                  value: participant.value,
                ),
              );
            }),
            itemCount: participants.length,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomButton(
              isPrimary: true,
              text: "Speichern",
              onClick: () => context.read<ChatBloc>().add(
                    ChatEditCompleted(
                      ChatRoomMetadata(
                        name: nameController.text,
                        chatRoomId: widget.currentMetadata?.chatRoomId ??
                            widget.uuid.v4(),
                        participants: participants.entries
                            .where((element) => element.value)
                            .map((e) => e.key)
                            .toList(),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      );
}
