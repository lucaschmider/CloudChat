import 'package:flutter/material.dart';

class ChatLoadingView extends StatelessWidget {
  const ChatLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      );
}
