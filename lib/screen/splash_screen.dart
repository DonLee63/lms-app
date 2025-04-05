import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/providers/profile_provider.dart';
import 'package:study_management_app/router.dart';
import 'package:animate_do/animate_do.dart'; // Thêm thư viện animate_do để tạo animation

import '../providers/logout_provider.dart';
import '../repositories/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? token = prefs.getString('token');

    if (isLoggedIn && token != null) {
      ref.read(authStateProvider.notifier).setAuthenticated();

      // Fetch profile nếu cần
      await ref.read(profileProvider.notifier).fetchProfile();

      // Chuyển hướng sang MainPage mà không cần quay lại màn hình cũ
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.mainpage,
        (route) => false,
      );
    } else {
      ref.read(authStateProvider.notifier).setUnauthenticated();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  // Provider để quản lý trạng thái đăng nhập
  final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    return AuthNotifier(AuthRepository());
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800], // Màu nền xanh đậm giống AppBar trong HomeScreen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo hoặc hình ảnh đại diện
            FadeInDown(
              duration: const Duration(milliseconds: 1000),
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Màu nền trắng cho logo
                ),
                child: const Icon(
                  Icons.book_rounded, // Icon tạm thời, bạn có thể thay bằng logo của ứng dụng
                  size: 100,
                  color: Colors.blue, // Màu icon
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tên ứng dụng
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: const Text(
                'Study Management App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Hiệu ứng loading
            ZoomIn(
              duration: const Duration(milliseconds: 1000),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}