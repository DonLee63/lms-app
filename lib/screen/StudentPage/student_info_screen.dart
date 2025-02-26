import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/screen/StudentPage/student_screen.dart';
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
    final savedUserRole = prefs.getString('role'); // Lấy role từ SharedPreferences

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

    // Kiểm tra thông tin dựa trên role
    if (userRole == 'student') {
      final student = await ref
          .read(studentRepositoryProvider.notifier)
          .showStudent(userId);

      if (student == null) {
        _showRoleAlert('Bạn chưa có thông tin sinh viên. Hãy tạo ngay!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StudentScreen(),
          ),
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
    final donvisFuture = ref.watch(donvisFutureProvider); // Lấy danh sách Đơn vị

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thông tin sinh viên'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: studentState.when(
        data: (student) {
          if (student == null) {
            return const Center(child: Text('No student data available.'));
          }
          final nganhsFuture = ref.watch(nganhsFutureProvider(student.donviId)); // Lấy danh sách Ngành dựa trên Đơn vị của sinh viên
          return nganhsFuture.when(
            data: (nganhs) {
              return donvisFuture.when(
                data: (donvis) {
                  // Tìm tên Ngành và Đơn vị dựa trên id
                  final donviName = donvis.firstWhere(
                    (donvi) => donvi['id'] == student.donviId,
                    orElse: () => {'title': 'Unknown'},
                  )['title'];

                  final nganhName = nganhs.firstWhere(
                    (nganh) => nganh['id'] == student.nganhId,
                    orElse: () => {'title': 'Unknown'},
                  )['title'];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            student.mssv,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Thông tin sinh viên',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        _buildInfoRow('Mã sinh viên', student.mssv),
                        const SizedBox(height: 10),
                        _buildInfoRow('Đơn vị', donviName), // Hiển thị tên Đơn vị
                        const SizedBox(height: 10),
                        _buildInfoRow('Ngành', nganhName), // Hiển thị tên Ngành
                        const SizedBox(height: 10),
                        _buildInfoRow('Khoá', student.khoa),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // Chuyển hướng tới trang chỉnh sửa thông tin sinh viên
                              Navigator.of(context).pushNamed(
                                AppRoutes.editstudent,
                                arguments: userId,
                              );
                            },
                            child: const Text('Chỉnh sửa thông tin sinh viên'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.blue,
                              textStyle: const TextStyle(fontSize: 18),
                              foregroundColor: Theme.of(context).colorScheme.onPrimary, // Màu chữ
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Failed to load donvis')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Failed to load nganhs')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Failed to load student data')),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}