import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final Widget? suffixIcon;
  final TextAlign? textAlign;
  final void Function(String text)? onChanged;

  const CustomTextInput({
    Key? key,
    required this.hintText,
    this.suffixIcon,
    this.textAlign,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textAlign: textAlign ?? TextAlign.start,
      controller: controller,
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
