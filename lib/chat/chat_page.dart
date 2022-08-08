import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/bloc/models/chat_user.dart';
import 'package:cloud_chat/chat/views/chat_loading_view.dart';
import 'package:cloud_chat/chat/views/chat_main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/chat_bloc.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => ChatBloc(
          logger: context.read(),
          repository: context.read(),
        ),
        child: BlocSelector<ChatBloc, ChatState, ChatUser?>(
          selector: (state) => state.sender,
          builder: (context, state) {
            if (state == null) return const ChatLoadingView();

            return const ChatMainView();
          },
        ),
      );
}
