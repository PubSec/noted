import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noted/constants/containershape.dart';
import 'package:noted/constants/mycolors.dart';
import 'package:noted/constants/sized_box.dart';
import 'package:noted/constants/text_style.dart';
import 'package:noted/services/auth/auth_exceptions.dart';
import 'package:noted/services/auth/bloc/auth_bloc.dart';
import 'package:noted/services/auth/bloc/auth_event.dart';
import 'package:noted/services/auth/bloc/auth_state.dart';
import 'package:noted/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak Password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email is already in use');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid Email');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: Text(
            'Register',
            style: textStyle(
              family: akira,
              size: 23,
              color: whiteColor,
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: myContainer(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter email and password to start creating your notes.',
                    style: textStyle(),
                  ),
                  mySizedBox(),
                  TextField(
                    style: textStyle(color: bgColor),
                    enableSuggestions: false,
                    autocorrect: false,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_rounded),
                      hintText: 'Enter your email here',
                      hintStyle: textStyle(size: 10, color: bgColor),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: whiteColor),
                          borderRadius: BorderRadius.all(Radius.circular(23))),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                  ),
                  mySizedBox(),
                  TextField(
                    style: textStyle(color: bgColor),
                    controller: _password,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password_rounded),
                      hintText: 'Enter your password here',
                      hintStyle: textStyle(size: 10, color: bgColor),
                      focusedBorder: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(23))),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                  ),
                  Column(
                    children: [
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            context.read<AuthBloc>().add(
                                  AuthEventRegister(
                                      email: email, passowrd: password),
                                );
                          },
                          child: Text(
                            'Register',
                            style: textStyle(color: null),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  const AuthEventLogOut(),
                                );
                          },
                          child: Text(
                            'Already registered? Login here!',
                            style: textStyle(color: null),
                          ),
                        ),
                      )
                    ],
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
