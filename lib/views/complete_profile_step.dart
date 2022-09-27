import 'package:cloud_chat/views/custom_button.dart';
import 'package:cloud_chat/views/custom_text_input.dart';
import 'package:flutter/material.dart';

class CompleteProfileStep extends StatefulWidget {
  final void Function(String fullName) onCompleted;

  const CompleteProfileStep({
    Key? key,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<CompleteProfileStep> createState() => _CompleteProfileStepState();
}

class _CompleteProfileStepState extends State<CompleteProfileStep> {
  final fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Bitte vervollständigen Sie ihr Profil",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          CustomTextInput(
            controller: fullNameController,
            hintText: "Voller Name",
            textAlign: TextAlign.center,
          ),
          CustomButton(
            isPrimary: true,
            text: "Speichern",
            onClick: () => widget.onCompleted(fullNameController.text),
          ),
        ],
      );
}
