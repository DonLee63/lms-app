import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/router.dart';
import '../providers/logout_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import 'AuthPage/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _role; // Vai trò của người dùng (student hoặc teacher)

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role'); // Lấy vai trò từ SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider);

    // Hiển thị màn hình loading nếu chưa tải xong vai trò
    if (_role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Chung",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            title: "Tài khoản",
            icon: Icons.person,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          // Hiển thị chức năng chỉ dành cho sinh viên
          if (_role == 'student')
            _buildSettingsTile(
              context,
              title: "Thông tin sinh viên",
              icon: Icons.school,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.studentinfo);

              },
            ),
          // Hiển thị chức năng chỉ dành cho giảng viên
          if (_role == 'teacher')
            _buildSettingsTile(
              context,
              title: "Thông tin giảng viên",
              icon: Icons.school,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.teacherinfo);

              },
            ),
          _buildSettingsTile(
            context,
            title: "Thông báo",
            icon: Icons.notifications,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.notification);
            },
          ),
          _buildSettingsTile(
            context,
            title: "Điều khoản và chính sách",
            icon: Icons.policy,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.policy);
            },
          ),
          _buildSettingsTile(
            context,
            title: "Đăng xuất",
            icon: Icons.logout,
            onTap: () => _handleLogout(context, ref),
          ),
          const SizedBox(height: 20),
          const Text(
            "Phản hồi",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            title: "Báo cáo lỗi",
            icon: Icons.warning_amber_rounded,
            onTap: () {
              // Điều hướng đến trang Report a Bug
            },
          ),
          _buildSettingsTile(
            context,
            title: "Gửi phản hồi",
            icon: Icons.send,
            onTap: () {
              // Điều hướng đến trang Send Feedback
            },
          ),
          _buildSettingsTile(
            context,
            title: "Dark Mode",
            icon: Icons.dark_mode,
            onTap: null,
            trailing: Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Đăng xuất'),
      content: const Text('Bạn chắc chắn muốn đăng xuất?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Thôi'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );

  if (shouldLogout == true) {
    // Đăng xuất Google
    await GoogleSignIn().signOut();

    // Đăng xuất Firebase
    await ref.read(authProvider.notifier).logout();
    
    // Reset profile nếu có
    ref.read(profileProvider.notifier).resetProfile();

    // Kiểm tra trạng thái đăng xuất
    if (ref.read(authProvider).status == AuthStatus.unauthenticated) {
      // Điều hướng về màn hình đăng nhập
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } else {
      // Hiển thị thông báo lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).errorMessage ?? 'Logout failed'),
        ),
      );
    }
  }
}

}
