import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

// Define login states
enum LoginStatus { initial, loading, success, error }

// LoginNotifier to manage login state
class LoginNotifier extends StateNotifier<LoginStatus> {
  final AuthRepository _authRepository;

  LoginNotifier(this._authRepository) : super(LoginStatus.initial);

  Future<void> login(String email, String password) async {
    state = LoginStatus.loading;
    try {
      final isLoggedIn = await _authRepository.login(email, password);

      if (isLoggedIn) {
        state = LoginStatus.success;
      } else {
        state = LoginStatus.error;
      }
    } catch (error) {
      print('LoginNotifier error: $error');
      state = LoginStatus.error;
    }
  }
}

// AuthRepository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// LoginNotifier provider
final loginProvider = StateNotifierProvider<LoginNotifier, LoginStatus>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginNotifier(authRepository);
});
