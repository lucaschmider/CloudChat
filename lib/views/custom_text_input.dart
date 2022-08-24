import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final Widget? suffixIcon;
  final TextAlign? textAlign;

  const CustomTextInput({
    Key? key,
    required TextEditingController controller,
    required this.hintText,
    this.suffixIcon,
    this.textAlign,
  })  : _controller = controller,
        super(key: key);

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: textAlign ?? TextAlign.start,
      controller: _controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        fillColor: Theme.of(context).colorScheme.surface,
        filled: true,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
