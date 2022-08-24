import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomButton extends StatelessWidget {
  final bool isPrimary;
  final String text;
  final void Function()? onClick;

  const CustomButton({
    Key? key,
    required this.isPrimary,
    required this.text,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonContent = Text(text);

    final style = ButtonStyle(
      padding: MaterialStateProperty.all(const EdgeInsets.all(18.0)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );

    final button = isPrimary
        ? ElevatedButton(
            onPressed: onClick,
            style: style,
            child: buttonContent,
          )
        : OutlinedButton(
            onPressed: onClick,
            style: style,
            child: buttonContent,
          );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: button,
    );
  }
}
