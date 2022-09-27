import 'package:cloud_chat/bloc/models/authentification_result.dart';

abstract class AuthenticationRepository {
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
    String username,
    String password,
  );
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
    String username,
    String password,
  );
  Future<void> signOut();

  Future<bool> isCurrentProfileCompleted();
  Future<void> setFullName(String fullName);
}
