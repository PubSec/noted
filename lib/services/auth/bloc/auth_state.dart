import 'package:flutter/foundation.dart' show immutable;
import 'package:noted/services/auth/auth_user.dart';

// const constructor is created beacuse a const constructor cannot call non-const contractor
@immutable
abstract class AuthState {
  const AuthState();
}

// A generic loading state that can be used anywhere
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

// imported AuthUser to use user during AuthStateLoggedIn
class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  const AuthStateLoggedOut(this.exception);
}

class AuthStateLogoutFailure extends AuthState {
  final Exception? exception;
  const AuthStateLogoutFailure(this.exception);
}
