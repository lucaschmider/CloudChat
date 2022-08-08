import 'package:cloud_chat/bloc/models/authentification_result.dart';

abstract class AuthentificationRepository {
  Future<AuthentificationResult> signInWithUsernameAndPasswordAsync(
    String username,
    String password,
  );
  Future<AuthentificationResult> signInWithGoogleAsync();
  Future<AuthentificationResult> signUpWithUsernameAndPassword(
    String username,
    String email,
    String fullName,
  );
  Future<void> signOut();

  Stream<void> createSignOutStream();
}
