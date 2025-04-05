import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_screen.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/univerinfo_provider.dart';
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

    if (userRole == 'teacher') {
      final teacher = await ref.read(teacherRepositoryProvider.notifier).showTeacher(userId);
      if (teacher == null && mounted) {
        _showRoleAlert('Bạn chưa có thông tin giảng viên. Hãy tạo ngay!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TeacherScreen()),
        );
      }
    }
  }

  void _showRoleAlert(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange[700],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final teacherState = ref.watch(teacherRepositoryProvider);
    final donvisFuture = ref.watch(donvisFutureProvider);
    final chuyennganhsFuture = ref.watch(chuyenNganhFutureProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Thông tin giảng viên',
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
      body: teacherState.when(
        data: (teacher) {
          if (teacher == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 48, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Không có dữ liệu giảng viên',
                    style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return chuyennganhsFuture.when(
            data: (chuyennganhs) => donvisFuture.when(
              data: (donvis) {
                final donviName = donvis.firstWhere(
                  (donvi) => donvi['id'] == teacher.maDonvi,
                  orElse: () => {'title': 'Chưa xác định'},
                )['title'];

                final chuyennganhName = chuyennganhs.firstWhere(
                  (nganh) => nganh['id'] == teacher.chuyenNganh,
                  orElse: () => {'title': 'Chưa xác định'},
                )['title'];

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: Center(
                            child: Column(
                              children: [
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
                                  teacher.mgv,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.blue[900],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thông tin giảng viên',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Card(
                            elevation: 6.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Mã giảng viên', teacher.mgv, isDarkMode),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Đơn vị', donviName, isDarkMode),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Chuyên ngành', chuyennganhName, isDarkMode),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Học hàm', teacher.hocHam ?? 'Chưa xác định', isDarkMode),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Học vị', teacher.hocVi ?? 'Chưa xác định', isDarkMode),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Loại giảng viên', teacher.loaiGiangvien, isDarkMode),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.editteacher,
                                arguments: userId,
                              );
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Chỉnh sửa thông tin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue))),
              error: (error, stack) => Center(
                child: Text(
                  'Không tải được danh sách đơn vị',
                  style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue))),
            error: (error, stack) => Center(
              child: Text(
                'Không tải được danh sách chuyên ngành',
                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue))),
        error: (error, stack) => Center(
          child: Text(
            'Không tải được thông tin giảng viên',
            style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.blue[900],
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}