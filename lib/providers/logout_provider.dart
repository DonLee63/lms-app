import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/auth_repository.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.unauthenticated,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  void setAuthenticated() {
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  void setUnauthenticated() {
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> logout() async {
  try {
    final success = await _repository.logout();
    
    if (success) {
      // Xóa token trong SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Chỉ xóa token
      await prefs.remove('teacher_id'); // Chỉ xóa token
      await prefs.remove('student_id'); // Chỉ xóa token
      
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } else {
      state = state.copyWith(
        errorMessage: 'Logout failed',
      );
    }
  } catch (e) {
    state = state.copyWith(
      errorMessage: e.toString(),
    );
  }
}
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRepository());
});