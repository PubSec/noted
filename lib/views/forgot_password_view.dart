import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noted/constants/containershape.dart';
import 'package:noted/constants/mycolors.dart';
import 'package:noted/constants/sized_box.dart';
import 'package:noted/constants/text_style.dart';
import 'package:noted/services/auth/bloc/auth_bloc.dart';
import 'package:noted/services/auth/bloc/auth_event.dart';
import 'package:noted/services/auth/bloc/auth_state.dart';
import 'package:noted/utilities/dialogs/error_dialog.dart';
import 'package:noted/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetDialog(context);
          } else if (state.exception != null) {
            await showErrorDialog(
              context,
              'We couldn\'t process your request. Please try again.',
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: Text(
            'Reset Password',
            style: textStyle(
              family: akira,
              size: 23,
              color: Colors.transparent,
            ),
          ),
          backgroundColor: bgColor,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: myContainer(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'If you forgot your password, simply enter your password and we will send you a link to reset your password.',
                    style: textStyle(),
                  ),
                  mySizedBox(height: 10),
                  TextField(
                    style: textStyle(),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofocus: true,
                    controller: _controller,
                    //my own code
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_rounded),
                      hintText: 'Type your email here.',
                      hintStyle: textStyle(color: null, size: 10),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: whiteColor),
                          borderRadius: BorderRadius.all(Radius.circular(23))),
                      fillColor: whiteColor,
                      filled: true,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final email = _controller.text;
                      context
                          .read<AuthBloc>()
                          .add(AuthEventForgotPassword(email: email));
                    },
                    child: Text(
                      'Send password reset link.',
                      style: textStyle(color: null),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: Text(
                      'Back to login page.',
                      style: textStyle(color: null),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
