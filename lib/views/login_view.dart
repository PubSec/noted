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

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException ||
              state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
                context, 'Cannot find a user with the entered credentials!');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: Text(
            'Login',
            style: textStyle(
              family: akira,
              size: 23,
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Please log in to your account in order to interact with and create notes.',
                    style: textStyle(),
                  ),
                  mySizedBox(),
                  TextField(
                    style: textStyle(color: bgColor),
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_rounded),
                      hintText: 'Enter your email here',
                      hintStyle: textStyle(size: 10, color: hintTextColor),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: bgColor),
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
                      hintStyle: textStyle(size: 10, color: hintTextColor),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: bgColor),
                          borderRadius: BorderRadius.all(Radius.circular(23))),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      context.read<AuthBloc>().add(
                            AuthEventLogIn(
                              email,
                              password,
                            ),
                          );
                    },
                    child: Text(
                      'Login',
                      style: textStyle(
                        color: null,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventForgotPassword(),
                          );
                    },
                    child: Text(
                      'Forgot your password? Reset here!',
                      style: textStyle(
                        color: null,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventShouldRegister(),
                          );
                    },
                    child: Text(
                      'Not registered yet? Register here!',
                      style: textStyle(
                        color: null,
                      ),
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
