import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

// to initialize firebase when the main ui of the app is called
class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

// Vandad set the password type to String but i don't think it would make any difference
// email and password are needed to login of course. made a constructor for them too.
class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

// Vandad didnt add a required
class AuthEventRegister extends AuthEvent {
  final String email;
  final String passowrd;
  const AuthEventRegister({required this.email, required this.passowrd});
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

// nothing is required to logout
class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
