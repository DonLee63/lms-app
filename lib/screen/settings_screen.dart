import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/router.dart';
import 'package:animate_do/animate_do.dart'; // Thêm thư viện animate_do để tạo animation
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ Dark Mode

    // Hiển thị màn hình loading nếu chưa tải xong vai trò
    if (_role == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.blue[800],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Màu xanh đậm chuyên nghiệp
        elevation: 0,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Màu chữ trắng để luôn dễ đọc
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Chung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            title: 'Tài khoản',
            icon: Icons.person,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
            index: 0,
          ),
          // Hiển thị chức năng chỉ dành cho sinh viên
          if (_role == 'student')
            _buildSettingsTile(
              context,
              title: 'Thông tin sinh viên',
              icon: Icons.school,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.studentinfo);
              },
              index: 1,
            ),
          // Hiển thị chức năng chỉ dành cho giảng viên
          if (_role == 'teacher')
            _buildSettingsTile(
              context,
              title: 'Thông tin giảng viên',
              icon: Icons.school,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.teacherinfo);
              },
              index: 1,
            ),
          _buildSettingsTile(
            context,
            title: 'Thông báo',
            icon: Icons.notifications,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.notification);
            },
            index: _role == null ? 1 : 2,
          ),
          _buildSettingsTile(
            context,
            title: 'Điều khoản và chính sách',
            icon: Icons.policy,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.policy);
            },
            index: _role == null ? 2 : 3,
          ),
          _buildSettingsTile(
            context,
            title: 'Dark Mode',
            icon: Icons.dark_mode,
            onTap: null,
            trailing: Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              activeColor: Colors.blue[800],
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            ),
            index: _role == null ? 3 : 4,
          ),
          _buildSettingsTile(
            context,
            title: 'Đăng xuất',
            icon: Icons.logout,
            onTap: () => _handleLogout(context, ref),
            iconColor: Colors.red,
            textColor: Colors.red,
            index: _role == null ? 4 : 5,
          ),
          const SizedBox(height: 20),
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Phản hồi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            title: 'Báo cáo lỗi',
            icon: Icons.warning_amber_rounded,
            onTap: () {
              // Điều hướng đến trang Report a Bug
            },
            index: 6,
          ),
          _buildSettingsTile(
            context,
            title: 'Gửi phản hồi',
            icon: Icons.send,
            onTap: () {
              // Điều hướng đến trang Send Feedback
            },
            index: 7,
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
    Color? iconColor,
    Color? textColor,
    required int index,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeInUp(
      duration: Duration(milliseconds: 600 + (index * 100)),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 4.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDarkMode ? Colors.grey[800]! : Colors.blue[50]!, // Gradient điều chỉnh theo chế độ
                isDarkMode ? Colors.grey[900]! : Colors.white,
              ],
            ),
          ),
          child: ScaleTransitionButton(
            onPressed: onTap,
            child: ListTile(
              leading: Icon(
                icon,
                color: iconColor ?? Colors.blue[800],
                size: 24,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              trailing: trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text(
          'Đăng xuất',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Bạn chắc chắn muốn đăng xuất?',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          ScaleTransitionButton(
            onPressed: () => Navigator.pop(context, false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Thôi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          ScaleTransitionButton(
            onPressed: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red[600]!,
                    Colors.red[800]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
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
            content: Text(ref.read(authProvider).errorMessage ?? 'Đăng xuất thất bại'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      }
    }
  }
}

// Widget tùy chỉnh để thêm hiệu ứng scale khi nhấn
class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const ScaleTransitionButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _ScaleTransitionButtonState createState() => _ScaleTransitionButtonState();
}

class _ScaleTransitionButtonState extends State<ScaleTransitionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              _controller.reverse();
              widget.onPressed!();
            }
          : null,
      onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}