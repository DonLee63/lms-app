import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:study_management_app/screen/TeacherPage/edit_teacher_screen.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_screen.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/univerinfo_provider.dart'; // Thêm provider của Đơn vị và Ngành
import '../../router.dart';
import '../AuthPage/register_screen.dart';

class TeacherInfoScreen extends ConsumerStatefulWidget {
  const TeacherInfoScreen({Key? key}) : super(key: key);

  @override
  _TeacherInfoScreenState createState() => _TeacherInfoScreenState();
}

class _TeacherInfoScreenState extends ConsumerState<TeacherInfoScreen> {
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
  if (userRole == 'teacher') {
    final student = await ref
        .read(teacherRepositoryProvider.notifier)
        .showTeacher(userId);

    if (student == null) {
      _showRoleAlert('Bạn chưa có thông tin giảng viên. Hãy tạo ngay!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TeacherScreen(),
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
    final teacherState = ref.watch(teacherRepositoryProvider);
    final donvisFuture = ref.watch(donvisFutureProvider); // Lấy danh sách Đơn vị
    final chuyennganhsFuture = ref.watch(chuyenNganhFutureProvider); // Lấy danh sách Ngành

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thông tin giảng viên'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: teacherState.when(
        data: (teacher) {
          if (teacher == null) {
            return const Center(child: Text('No teacher data available.'));
          }
          return chuyennganhsFuture.when(
            data: (chuyennganhs) {
              return donvisFuture.when(
                data: (donvis) {
                  // Tìm tên Ngành và Đơn vị dựa trên id
                  final donviName = donvis.firstWhere(
                    (donvi) => donvi['id'] == teacher.maDonvi,
                    orElse: () => {'title': 'Unknown'},
                  )['title'];

                  final chuyennganhName = chuyennganhs.firstWhere(
                    (nganh) => nganh['id'] == teacher.chuyenNganh,
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
                            teacher.mgv,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Thông tin giảng viên',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        _buildInfoRow('Mã giảng viên', teacher.mgv),
                        const SizedBox(height: 10),
                        _buildInfoRow('Đơn vị', donviName), // Hiển thị tên Đơn vị
                        const SizedBox(height: 10),
                        _buildInfoRow('Chuyên ngành', chuyennganhName), // Hiển thị tên Ngành
                        const SizedBox(height: 10),
                        _buildInfoRow('Học hàm', teacher.hocHam ?? 'Unknown'),
                        const SizedBox(height: 10),
                        _buildInfoRow('Học vị', teacher.hocVi ?? 'Unknown'),
                        const SizedBox(height: 10),
                        _buildInfoRow('Loại giảng viên', teacher.loaiGiangvien),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // Chuyển hướng tới trang chỉnh sửa thông tin giảng viên
                              Navigator.of(context).pushNamed(
                              AppRoutes.editteacher,
                              arguments: userId,
                            );
                            },
                            child: const Text('Chỉnh sửa thông tin giảng viên'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue,
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
            error: (error, stack) => Center(child: Text('Failed to load chuyennganhs')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Failed to load teacher data')),
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
