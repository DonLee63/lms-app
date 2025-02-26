import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/providers/profile_provider.dart';
import 'package:study_management_app/router.dart';

import '../providers/logout_provider.dart';
import '../repositories/auth_repository.dart';


class SplashScreen extends ConsumerStatefulWidget {
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
