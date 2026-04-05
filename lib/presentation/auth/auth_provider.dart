import 'package:email_snaarp/data/repositories/auth_repository_impl.dart';
import 'package:email_snaarp/domain/repositories/auth_repository.dart';
import 'package:email_snaarp/domain/usecases/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for the repository and use case
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<bool> {
  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  AuthNotifier(this._loginUseCase, this._authRepository) : super(false) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = await _authRepository.isAuthenticated();
  }

  Future<bool> login(String email, String password) async {
    state = await _loginUseCase.call(email, password);
    return state;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(
    ref.read(loginUseCaseProvider),
    ref.read(authRepositoryProvider),
  );
});