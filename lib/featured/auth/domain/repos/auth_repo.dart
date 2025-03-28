/*
Auth Repository - Outlines the possible auth operations for this app.
*/

import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String password);

  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password);

  Future<void> logout();

  Future<void> sendEmail();

  Future<AppUser?> getCurrentUser();

  Future<bool> checkLockState(String uid);
}
