import 'package:cloud_chat/chat/bloc/chat_bloc.dart';
import 'package:cloud_chat/chat/bloc/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMessageInput extends StatefulWidget {
  const ChatMessageInput({Key? key}) : super(key: key);

  @override
  State<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends State<ChatMessageInput> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "Nachricht eingeben",
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            suffixIcon: IconButton(
              onPressed: () {
                context.read<ChatBloc>().add(
                      ChatTextSent(_controller.text),
                    );
                _controller.clear();
              },
              icon: const Icon(Icons.send),
            ),
          ),
        ),
      );
}
