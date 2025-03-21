import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/apilist.dart';
import '../../providers/profile_provider.dart';
import '../router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends ConsumerState<HomeScreen> {
  String? _role; // Vai trò của người dùng (student hoặc teacher)
  int? _studentId; // ID của sinh viên
  int? _teacherId; // ID của sinh viên

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndStudentId();
  }

  Future<void> _loadUserRoleAndStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role'); // Lấy vai trò từ SharedPreferences
      _studentId = prefs.getInt('student_id'); // Lấy student_id từ SharedPreferences
      _teacherId = prefs.getInt('teacher_id'); // Lấy teacher_id từ SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: profileState.profile.photo.isNotEmpty
                  ? (profileState.profile.photo.startsWith('http')
                      ? NetworkImage(profileState.profile.photo)
                      : NetworkImage(url_image + profileState.profile.photo))
                  : null,
              child: profileState.profile.photo.isEmpty
                  ? const Icon(Icons.person, color: Colors.blue)
                  : null,
            ),
            const SizedBox(width: 8.0),
            Text(
              profileState.profile.full_name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Banner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Danh mục',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 10),
            if (_role == 'student') 
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildCategoryButton('Đăng ký học phần', Icons.app_registration, () {
                    if (_studentId != null) {
                      // Điều hướng đến màn hình đăng ký học phần và truyền studentId
                      Navigator.of(context).pushNamed(AppRoutes.courses, arguments: _studentId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy student_id')),
                      );
                    }
                  }),
                  _buildCategoryButton('Lich thi', Icons.schedule, () {
                    if (_studentId != null) {
                      // Điều hướng đến màn hình đăng ký học phần và truyền studentId
                      Navigator.of(context).pushNamed(AppRoutes.examschedule, arguments: _studentId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy student_id')),
                      );
                    }
                  }),
                  _buildCategoryButton('Khảo sát', Icons.class_, () {
                    if (_teacherId != null) {
                      // Điều hướng đến màn hình đăng ký học phần và truyền studentId
                     Navigator.of(context).pushNamed(AppRoutes.studentSurvey);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy student_id')),
                      );
                    }
                  }),
                  _buildCategoryButton('Bài tập', Icons.class_, () {
                    if (_teacherId != null) {
                      // Điều hướng đến màn hình đăng ký học phần và truyền studentId
                     Navigator.of(context).pushNamed(AppRoutes.studentExercises, arguments: _studentId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy student_id')),
                      );
                    }
                  }),
                   _buildCategoryButton('Điểm số', Icons.class_, () {
                    if (_teacherId != null) {
                      // Điều hướng đến màn hình đăng ký học phần và truyền studentId
                     Navigator.of(context).pushNamed(AppRoutes.studentExercises);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy student_id')),
                      );
                    }
                  }),
                ],
              ),
              
            if (_role == 'teacher') 
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildCategoryButton('Lớp học phần', Icons.app_registration, () {
                    if (_teacherId != null) {
                      // Điều hướng đến màn hình đăng ký học phần và truyền studentId
                     Navigator.of(context).pushNamed(AppRoutes.phancong, arguments: _teacherId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy teacher_id')),
                      );
                    }
                  }),
                  _buildCategoryButton('Lớp học', Icons.class_, () {
                    if (_teacherId != null) {
                      // Điều hướng đến màn hình đăng ký học phần và truyền studentId
                     Navigator.of(context).pushNamed(AppRoutes.getClass, arguments: _teacherId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy teacher_id')),
                      );
                    }
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
