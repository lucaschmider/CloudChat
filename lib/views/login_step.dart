import 'package:cloud_chat/views/custom_button.dart';
import 'package:cloud_chat/views/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class LoginStep extends StatefulWidget {
  final void Function(String userName, String password) onPasswordLogin;
  final void Function(String userName, String password) onCreateUser;
  final bool isLoggedIn;

  const LoginStep({
    Key? key,
    required this.onPasswordLogin,
    required this.onCreateUser,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  State<LoginStep> createState() => _LoginStepState();
}

class _LoginStepState extends State<LoginStep> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) => !widget.isLoggedIn
      ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Bitte geben Sie Ihre Zugangsdaten an",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            CustomTextInput(
              controller: emailController,
              hintText: "E-Mail Adresse",
              textAlign: TextAlign.center,
            ),
            CustomTextInput(
              controller: passwordController,
              hintText: "Password",
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  isPrimary: true,
                  text: "Anmelden",
                  onClick: () => widget.onPasswordLogin(
                    emailController.text,
                    passwordController.text,
                  ),
                ),
                CustomButton(
                  isPrimary: false,
                  text: "Registrieren",
                  onClick: () => widget.onCreateUser(
                    emailController.text,
                    passwordController.text,
                  ),
                ),
              ],
            ),
          ],
        )
      : const Text("Angemeldet");
}
