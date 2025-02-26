import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/repositories/google_auth_reponsitory.dart';
import '../constants/pref_data.dart';

// Định nghĩa trạng thái cho quá trình đăng nhập bằng Google
enum GoogleAuthStatus { initial, loading, success, error }

class GoogleAuthNotifier extends StateNotifier<GoogleAuthStatus> {
  final GoogleAuthRepository _googleAuthRepository;
  GoogleAuthNotifier(this._googleAuthRepository) : super(GoogleAuthStatus.initial);

  String? errorMessage;
  int? userId;
  String? token;

  // Cập nhật phương thức signInWithGoogle để nhận tham số role
  Future<void> signUpWithGoogle({required String role}) async {
    state = GoogleAuthStatus.loading;

    try {
      // Gọi hàm signInWithGoogle từ repository và truyền role vào
      final response = await _googleAuthRepository.signUpWithGoogle(role: role);

      final fetchedUserId = response['userId']; // Lấy userId từ phản hồi
      final fetchedToken = response['token'];   // Lấy token từ phản hồi

      if (fetchedUserId != null && fetchedToken != null) {
        // Lưu token vào SharedPreferences
        await PrefData.setToken(fetchedToken);

        userId = fetchedUserId; // Gán userId vào thuộc tính
        token = fetchedToken;   // Gán token vào thuộc tính
        state = GoogleAuthStatus.success;
      } else {
        throw Exception('Đăng ký thất bại');
      }
    } catch (error) {
      errorMessage = error.toString();
      state = GoogleAuthStatus.error;
    }
  }

  Future<void> signInWithGoogle() async {
    state = GoogleAuthStatus.loading;

    try {
      final response = await _googleAuthRepository.signInWithGoogle(); // Gọi hàm signInWithGoogle từ repository
      final fetchedUserId = response['userId']; // Lấy userId từ phản hồi
      final fetchedToken = response['token'];   // Lấy token từ phản hồi

      if (fetchedUserId != null && fetchedToken != null) {
        // Lưu token vào SharedPreferences
        await PrefData.setToken(fetchedToken);

        userId = fetchedUserId; // Gán userId vào thuộc tính
        token = fetchedToken;   // Gán token vào thuộc tính
        state = GoogleAuthStatus.success;
      } else {
        throw Exception('Đăng nhập thất bại!');
      }
    } catch (error) {
      errorMessage = error.toString();
      state = GoogleAuthStatus.error;
    }
  }
}

final googleAuthProvider = StateNotifierProvider<GoogleAuthNotifier, GoogleAuthStatus>((ref) {
  final googleAuthRepository = GoogleAuthRepository(); // Inject repository
  return GoogleAuthNotifier(googleAuthRepository);
});
