import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noted/constants/containershape.dart';
import 'package:noted/constants/mycolors.dart';
import 'package:noted/constants/text_style.dart';
import 'package:noted/services/auth/bloc/auth_bloc.dart';
import 'package:noted/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text(
          'Verify Email',
          style: textStyle(
            family: akira,
            size: 23,
            color: whiteColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: myContainer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'We sent you an email verification. Please open it to verify your account',
                style: textStyle(),
              ),
              Text(
                'If you have not received a verification email. Please press the button below.',
                style: textStyle(),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventSendEmailVerification(),
                      );
                },
                child: Text(
                  'Send email verification',
                  style: textStyle(color: null),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: Text(
                  'Go back to login',
                  style: textStyle(color: null),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
