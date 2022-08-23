import 'package:cloud_chat/bloc/cloud_chat_bloc.dart';
import 'package:cloud_chat/utils/clamp.dart';
import 'package:cloud_chat/views/backend_selector.dart';
import 'package:cloud_chat/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({Key? key}) : super(key: key);

  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  @override
  Widget build(BuildContext context) {
    final boxWidth = clamp(
      minimum: 300.0,
      maximum: 800.0,
      base: MediaQuery.of(context).size.width * 0.5,
    );
    final boxHeight = clamp(
      minimum: 300.0,
      maximum: 600.0,
      base: MediaQuery.of(context).size.height * 0.5,
    );

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(),
              ]),
          child: SizedBox(
            width: boxWidth,
            height: boxHeight,
            child: BlocBuilder<CloudChatBloc, CloudChatState>(
              builder: (context, state) {
                if (state is CloudChatInitial) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Stack(
                  children: [
                    AnimatedPositioned(
                      width: boxWidth,
                      left: (state is! CloudChatConnected) ? boxWidth : 0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInCubic,
                      child: LoginView(
                        height: boxHeight,
                        onLogin: (username, password) => context
                            .read<CloudChatBloc>()
                            .add(CloudChatPasswordLoginRequested(
                                username, password)),
                      ),
                    ),
                    AnimatedPositioned(
                      width: boxWidth,
                      left: (state is CloudChatConnected) ? -boxWidth : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInCubic,
                      child: BackendSelector(
                        height: boxHeight,
                        connectors: state.availableConnectors,
                        onBackendSelected: (selectedBackend) => context
                            .read<CloudChatBloc>()
                            .add(
                                CloudChatBackendSelected(selectedBackend.name)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
