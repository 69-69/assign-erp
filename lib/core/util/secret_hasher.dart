import 'package:bcrypt/bcrypt.dart';

/// [SecretHasher] Utility class for hashing and verifying secrets using bcrypt.
class SecretHasher {
  /// [hash] Generates a bcrypt hash from the provided plain-text secret.
  static String hash(String plainText) =>
      BCrypt.hashpw(plainText, BCrypt.gensalt());

  /// [verify] Verifies a plain-text secret against a bcrypt hash.
  static bool verify(String plainText, {required String hashed}) =>
      BCrypt.checkpw(plainText, hashed);
}
