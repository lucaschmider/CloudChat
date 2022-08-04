import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/models/chat_message.dart';

class ChatRoomView extends StatelessWidget {
  const ChatRoomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocSelector<ChatBloc, ChatState, List<ChatMessage>>(
        selector: (state) => state.messages,
        builder: (context, state) => ListView.builder(
          itemBuilder: (context, index) => Text(state.elementAt(index).text),
          itemCount: state.length,
        ),
      );
}
