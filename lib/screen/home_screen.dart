import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart'; // Thêm thư viện animate_do để tạo animation dễ dàng
import '../../constants/apilist.dart';
import '../../providers/profile_provider.dart';
import '../router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  String? _role; // Vai trò của người dùng (student hoặc teacher)
  int? _studentId; // ID của sinh viên
  int? _teacherId; // ID của giảng viên

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
      // Debug để kiểm tra giá trị role
      print('Role: $_role, Student ID: $_studentId, Teacher ID: $_teacherId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ tối
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100], // Màu nền tùy thuộc vào chế độ tối
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Màu xanh đậm chuyên nghiệp
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: profileState.profile.photo.isNotEmpty
                  ? (profileState.profile.photo.startsWith('http')
                      ? NetworkImage(profileState.profile.photo)
                      : NetworkImage(url_image + profileState.profile.photo))
                  : null,
              child: profileState.profile.photo.isEmpty
                  ? const Icon(Icons.person, color: Colors.blue, size: 24)
                  : null,
            ),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào,',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                ),
                Text(
                  profileState.profile.full_name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần tiêu đề "Welcome to my app" được thiết kế lại
            Container(
              height: 200, // Tăng chiều cao để tạo không gian thoáng hơn
              width: double.infinity,
              decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 10, 59, 114)!, const Color.fromARGB(255, 110, 178, 233)!], // Gradient màu xanh chuyên nghiệp
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // borderRadius: const BorderRadius.only(
              //   bottomLeft: Radius.circular(30),
              //   bottomRight: Radius.circular(30),
              // ),
              ),
              child: Center(
              child: FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                  Icons.school,
                  size: 50,
                  color: Colors.white, // Icon màu trắng nổi bật
                  ),
                  SizedBox(height: 10),
                  Text(
                  'Welcome to My App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Màu chữ trắng chuyên nghiệp
                  ),
                  ),
                  SizedBox(height: 5),
                  Text(
                  'Khoá luận của Lê Quốc Đông',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // Màu chữ phụ nhẹ nhàng
                  ),
                  ),
                ],
                ),
              ),
              ),
            ),
            // Phần danh mục với bo cong phía trên
            Container(
              width: double.infinity,
              
                decoration: BoxDecoration(
                gradient: isDarkMode
                  ? const LinearGradient(
                  colors: [Color(0xFF000000), Color.fromARGB(255, 38, 103, 208)], // Gradient for dark mode
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  )
                  : const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color.fromARGB(255, 96, 194, 255)], // Gradient for light mode
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  ),
                boxShadow: [
                  BoxShadow(
                  color: isDarkMode
                    ? Colors.black.withOpacity(0.5) // Shadow for dark mode
                    : Colors.grey.withOpacity(0.5), // Shadow for light mode
                  offset: const Offset(0, 4), // Horizontal and vertical offset
                  blurRadius: 20, // Blur radius
                  spreadRadius: 5, // Spread radius
                  ),
                ],
              //   borderRadius: const BorderRadius.only(
              //   topLeft: Radius.circular(40),
              //   topRight: Radius.circular(40),
              // ),
                ),
              
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'Danh mục',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.blue, // Màu chữ trắng
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_role == 'student')
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildCategoryCard(
                            'Đăng ký học phần',
                            Icons.grid_view, // Icon giống hình
                            Colors.blue, // Màu giống hình
                            () {
                              if (_studentId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.courses, arguments: _studentId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy student_id')),
                                );
                              }
                            },
                            index: 0,
                          ),
                          _buildCategoryCard(
                            'Lịch thi',
                            Icons.bookmark, // Icon giống hình
                            Colors.green, // Màu giống hình
                            () {
                              if (_studentId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.examschedule, arguments: _studentId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy student_id')),
                                );
                              }
                            },
                            index: 1,
                          ),
                          _buildCategoryCard(
                            'Khảo sát',
                            Icons.star, // Icon giống hình
                            Colors.orange, // Màu giống hình
                            () {
                              if (_studentId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.studentSurvey, arguments: _studentId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy student_id')),
                                );
                              }
                            },
                            index: 2,
                          ),
                          _buildCategoryCard(
                            'Bài tập',
                            Icons.assignment,
                            Colors.red,
                            () {
                              if (_studentId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.studentExercises, arguments: _studentId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy student_id')),
                                );
                              }
                            },
                            index: 3,
                          ),
                          _buildCategoryCard(
                            'Điểm số',
                            Icons.grade,
                            Colors.purple,
                            () {
                              if (_studentId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.studentscorecourse, arguments: _studentId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy student_id')),
                                );
                              }
                            },
                            index: 4,
                          ),
                          _buildCategoryCard(
                            'Tài liệu học tập',
                            Icons.book,
                            Colors.teal,
                            () {
                              if (_studentId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.studentenrolled, arguments: _studentId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy student_id')),
                                );
                              }
                            },
                            index: 5,
                          ),
                        ],
                      ),
                    if (_role == 'teacher')
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 1,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.6, // Giảm tỷ lệ để card cao hơn, lấp đầy khoảng trống
                        children: [
                          _buildCategoryCard(
                            'Lớp học phần',
                            Icons.grid_view, // Icon giống hình
                            Colors.blue, // Màu giống hình
                            () {
                              if (_teacherId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.phancong, arguments: _teacherId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy teacher_id')),
                                );
                              }
                            },
                            index: 0,
                          ),
                          _buildCategoryCard(
                            'Lớp học',
                            Icons.bookmark, // Icon giống hình
                            Colors.green, // Màu giống hình
                            () {
                              if (_teacherId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.getClass, arguments: _teacherId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy teacher_id')),
                                );
                              }
                            },
                            index: 1,
                          ),
                          _buildCategoryCard(
                            'Điểm',
                            Icons.star, // Icon giống hình
                            Colors.orange, // Màu giống hình
                            () {
                              if (_teacherId != null) {
                                Navigator.of(context).pushNamed(AppRoutes.teacherhocphan, arguments: _teacherId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không tìm thấy teacher_id')),
                                );
                              }
                            },
                            index: 2,
                          ),
                        ],
                      ),
                    if (_role != 'student' && _role != 'teacher')
                      const Center(
                        child: Text(
                          'Vai trò không hợp lệ. Vui lòng đăng nhập lại.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, VoidCallback onPressed, {required int index}) {
    return FadeInUp(
      duration: Duration(milliseconds: 600 + (index * 100)),
      child: GestureDetector(
        onTap: onPressed,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color, // Sử dụng màu đồng nhất thay vì gradient để giống hình
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}