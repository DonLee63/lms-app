import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/pref_data.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

// Định nghĩa trạng thái cho quá trình đăng ký
enum RegistrationStatus { initial, loading, success, error }

class RegistrationNotifier extends StateNotifier<RegistrationStatus> {
  final AuthRepository _authRepository;
  RegistrationNotifier(this._authRepository) : super(RegistrationStatus.initial);

  String? errorMessage;
  int? userId;
  String? token;

  Future<void> register(User user) async {
    state = RegistrationStatus.loading;

    try {
      final response = await _authRepository.register(user); // Gọi hàm register từ repository
      final fetchedUserId = response['userId']; // Lấy userId từ phản hồi
      final fetchedToken = response['token'];   // Lấy token từ phản hồi

      if (fetchedUserId != null && fetchedToken != null) {
        // Lưu token vào SharedPreferences
        await PrefData.setToken(fetchedToken);

        userId = fetchedUserId; // Gán userId vào thuộc tính
        token = fetchedToken;   // Gán token vào thuộc tính
        state = RegistrationStatus.success;
      } else {
        throw Exception('User ID hoặc Token không hợp lệ');
      }
    } catch (error) {
      errorMessage = error.toString();
      state = RegistrationStatus.error;
    }
  }
}





final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationStatus>((ref) {
  final authRepository = AuthRepository(); // Inject repository
  return RegistrationNotifier(authRepository);
});

