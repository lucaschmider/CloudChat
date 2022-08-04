import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/chat_page.dart';
import 'package:cloud_chat/console_logger.dart';
import 'package:cloud_chat/mocked_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logger.dart';

class CloudChatApp extends StatelessWidget {
  const CloudChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ChatRepository>(
                create: (context) => MockedRepository()),
            RepositoryProvider<Logger>(create: (context) => ConsoleLogger()),
          ],
          child: const ChatPage(),
        ),
      );
}
