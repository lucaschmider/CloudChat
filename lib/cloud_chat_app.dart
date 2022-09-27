import 'package:cloud_chat/bloc/backend_connector_repository.dart';
import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/chat_page.dart';
import 'package:cloud_chat/console_logger.dart';
import 'package:cloud_chat/views/initialization_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/cloud_chat_bloc.dart';
import 'implementations/backend_connector_repository.dart';
import 'logger.dart';

class CloudChatApp extends StatelessWidget {
  const CloudChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color.fromRGBO(246, 174, 45, 1),
            onPrimary: Color.fromRGBO(73, 73, 73, 1),
            secondary: Color.fromRGBO(73, 73, 73, 1),
            onSecondary: Color.fromRGBO(252, 252, 252, 1),
            background: Color.fromRGBO(47, 47, 47, 1),
            onBackground: Color.fromRGBO(252, 252, 252, 1),
            surface: Color.fromRGBO(73, 73, 73, 1),
            onSurface: Color.fromRGBO(252, 252, 252, 1),
          ),
        ),
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<BackendConnectorRepository>(
                create: (context) => BackendConnectorRegistry()),
            RepositoryProvider<Logger>(
                create: (context) => const ConsoleLogger()),
          ],
          child: BlocProvider(
            create: (context) => CloudChatBloc(
              connectorRepository: context.read(),
              logger: context.read(),
            ),
            child: BlocBuilder<CloudChatBloc, CloudChatState>(
              builder: (context, state) {
                if (state is CloudChatSignedIn) {
                  return FutureBuilder(
                      future: state.connector!.chatRepositoryFactory(),
                      builder:
                          (context, AsyncSnapshot<ChatRepository> snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return RepositoryProvider<ChatRepository>(
                          create: (context) => snapshot.data!,
                          child: const ChatPage(),
                        );
                      });
                }

                return const InitializationPage();
              },
            ),
          ),
        ),
      );
}
