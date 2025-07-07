import 'package:bcrypt/bcrypt.dart';

class PasswordHash {
  // Hash a password
  static String hashPassword(String password) => BCrypt.hashpw(password, BCrypt.gensalt());

  // Verify a password against a hash
  static bool verifyPassword(String password, {required String hash}) => BCrypt.checkpw(password, hash);
}
