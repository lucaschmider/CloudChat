import 'package:cloud_chat/bloc/cloud_chat_bloc.dart';
import 'package:cloud_chat/utils/clamp.dart';
import 'package:cloud_chat/views/complete_profile_step.dart';
import 'package:cloud_chat/views/login_step.dart';
import 'package:cloud_chat/views/select_backend_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({Key? key}) : super(key: key);

  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  int getInitializationLevel(CloudChatState state) {
    if (state is CloudChatInitial) return 0;
    if (state is CloudChatConnectorsKnown) return 1;
    if (state is CloudChatConnected) return 2;
    if (state is CloudChatProfileCompletion) return 3;
    if (state is CloudChatSignedIn) return 4;

    return 0;
  }

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
                final initializationLevel = getInitializationLevel(state);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (initializationLevel == 0)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      if (initializationLevel >= 1)
                        SelectBackendStep(
                          connectors: state.availableConnectors,
                          onBackendSelected: (selection) => context
                              .read<CloudChatBloc>()
                              .add(CloudChatBackendSelected(selection.name)),
                        ),
                      if (initializationLevel >= 2)
                        LoginStep(
                          onPasswordLogin: (userName, password) => context
                              .read<CloudChatBloc>()
                              .add(CloudChatPasswordLoginRequested(
                                  userName, password)),
                          onCreateUser: (username, password) => context
                              .read<CloudChatBloc>()
                              .add(CloudChatUserCreated(username, password)),
                          isLoggedIn: initializationLevel > 2,
                        ),
                      if (initializationLevel >= 3)
                        CompleteProfileStep(
                          onCompleted: (fullName) =>
                              context.read<CloudChatBloc>().add(
                                    CloudChatProfileCompleted(
                                      fullName: fullName,
                                    ),
                                  ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
