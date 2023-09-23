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
  final dynamic password;
  const AuthEventLogIn(this.email, this.password);
}

// nothing is required to logout
class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
