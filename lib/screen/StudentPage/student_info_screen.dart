import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/screen/StudentPage/student_screen.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/student_provider.dart';
import '../../providers/univerinfo_provider.dart';
import '../../router.dart';
import '../AuthPage/register_screen.dart';

class StudentInfoScreen extends ConsumerStatefulWidget {
  const StudentInfoScreen({Key? key}) : super(key: key);

  @override
  _StudentInfoScreenState createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends ConsumerState<StudentInfoScreen> {
  int userId = 0;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('userId');
    final savedUserRole = prefs.getString('role');

    if (savedUserId == null || savedUserRole == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID or Role not found. Please register again.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SignupPage()),
        );
      }
      return;
    }

    setState(() {
      userId = savedUserId;
      userRole = savedUserRole;
    });

    if (userRole == 'student') {
      final student = await ref.read(studentRepositoryProvider.notifier).showStudent(userId);

      if (student == null) {
        _showRoleAlert('Bạn chưa có thông tin sinh viên. Hãy tạo ngay!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => StudentScreen()),
        );
      }
    }
  }

  void _showRoleAlert(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentRepositoryProvider);
    final donvisFuture = ref.watch(donvisFutureProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Thông tin sinh viên',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: studentState.when(
        data: (student) {
          if (student == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No student data available.',
                    style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          final nganhsFuture = ref.watch(nganhsFutureProvider(student.donviId));
          return nganhsFuture.when(
            data: (nganhs) {
              return donvisFuture.when(
                data: (donvis) {
                  final donviName = donvis.firstWhere(
                    (donvi) => donvi['id'] == student.donviId,
                    orElse: () => {'title': 'Unknown'},
                  )['title'];

                  final nganhName = nganhs.firstWhere(
                    (nganh) => nganh['id'] == student.nganhId,
                    orElse: () => {'title': 'Unknown'},
                  )['title'];

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue[100],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              student.mssv,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thông tin sinh viên',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Card(
                              elevation: 6.0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              color: isDarkMode ? Colors.grey[850] : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    _buildInfoRow('Mã sinh viên', student.mssv, isDarkMode),
                                    _buildInfoRow('Đơn vị', donviName, isDarkMode),
                                    _buildInfoRow('Ngành', nganhName, isDarkMode),
                                    _buildInfoRow('Khóa', student.khoa, isDarkMode),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.editstudent,
                                  arguments: userId,
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Chỉnh sửa thông tin'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(
                    'Failed to load donvis',
                    style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Failed to load nganhs',
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: isDarkMode ? Colors.red[300] : Colors.red[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load student data',
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getIconForLabel(label),
                color: isDarkMode ? Colors.blue[300] : Colors.blue[800],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.blue[900],
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Mã sinh viên':
        return Icons.badge;
      case 'Đơn vị':
        return Icons.account_balance;
      case 'Ngành':
        return Icons.school;
      case 'Khóa':
        return Icons.calendar_today;
      default:
        return Icons.info;
    }
  }
}