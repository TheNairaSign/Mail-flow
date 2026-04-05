import 'package:email_snaarp/core/constants/app_constants.dart';
import 'package:email_snaarp/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _authTokenKey = 'authToken';

  @override
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == AppConstants.mockEmail && password == AppConstants.mockPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, 'mock_auth_token');
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) != null;
  }
}