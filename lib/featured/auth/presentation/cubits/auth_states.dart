
import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';

abstract class AuthState {}

// initial
class AuthInitial extends AuthState {}

// loading..
class AuthLoading extends AuthState {}

// authenticated
class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

// unauthenticated
class Unauthenticated extends AuthState {}

// unauthenticated
class Lock extends AuthState {}


// errors..
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}