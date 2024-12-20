/*
Auth Cubit: State Management
*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';
import 'package:social_network_lite/featured/auth/domain/repos/auth_repo.dart';

import 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

// check if user is already authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      // print("toi chua dang nhap va dang trong ham checkAuth");

      emit(Unauthenticated());
    }
  }

// get current user
  AppUser? get currentUser => _currentUser;

// login with email + pw
  Future<void> login(String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);

      if (user != null) {
        // print("inif1");
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        // print("inif2");

        emit(Unauthenticated());
      }
    } catch (e) {
      // print("catch error");
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

// register with email + pw
  Future<void> register(String name, String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
  // logout
  Future<void> logout() async {
    authRepo.logout();
    emit(Unauthenticated());
  }
}
