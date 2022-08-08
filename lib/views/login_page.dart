import 'package:cloud_chat/views/backend_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cloud_chat_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CloudChatBloc, CloudChatState>(
        builder: (context, state) {
          if (state is CloudChatInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: BackendSelector(
              connectors: state.availableConnectors,
              onBackendSelected: (selection) => context
                  .read<CloudChatBloc>()
                  .add(CloudChatBackendSelected(selection.name)),
            ),
          );
        },
      );
}
