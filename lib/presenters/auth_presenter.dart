import '../models/account_info.dart';
import '../models/auth_model.dart';

class AuthPresenter {
  final AuthModel _model = AuthModel();

  Future<String?> login(String email, String password) {
    return _model.login(email, password);
  }

  Future<String?> signUp(String email, String password, AccountInfo info) {
    return _model.signUp(email, password, info);
  }

  Future<void> logout() => _model.signOut();

  Stream authStateChanges() => _model.authStateChanges();

  String? getCurrentUserEmail() => _model.currentUser?.email;

  Future<String?> resetPassword(String email) {
  return _model.resetPassword(email);
  }

  Future<AccountInfo?> getAccountInfo() => _model.getAccountInfo();

}
