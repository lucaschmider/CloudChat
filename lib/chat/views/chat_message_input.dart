import 'package:cloud_chat/chat/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../views/custom_text_input.dart';

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
        child: CustomTextInput(
          controller: _controller,
          hintText: "Nachricht eingeben",
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
      );
}
