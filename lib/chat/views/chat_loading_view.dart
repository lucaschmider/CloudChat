import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatLoadingView extends StatelessWidget {
  const ChatLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      );
}
