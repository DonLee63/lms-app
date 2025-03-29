import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/enrollment.dart';
import '../../providers/course_provider.dart';
import 'student_score_detail_screen.dart'; // Import màn hình xem điểm chi tiết
import 'student_progress_screen.dart'; // Import màn hình theo dõi tiến độ học tập

class StudentScoresCourses extends ConsumerWidget {
  final int studentId;

  const StudentScoresCourses({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledCoursesAsync = ref.watch(enrolledCoursesProvider(studentId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Điểm học phần'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchCourses(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchCourses(ref);
        },
        child: enrolledCoursesAsync.when(
          data: (enrollments) => _buildCourseList(context, enrollments),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Lỗi: $error')),
        ),
      ),
      // Thêm FloatingActionButton để điều hướng đến StudentProgressScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentProgressScreen(
                studentId: studentId,
              ),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.trending_up), // Icon biểu thị tiến độ học tập
        tooltip: 'Theo dõi tiến độ học tập',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Đặt ở góc dưới bên phải
    );
  }

  Widget _buildCourseList(BuildContext context, List<Enrollment> enrollments) {
    if (enrollments.isEmpty) {
      return const Center(child: Text('Bạn chưa đăng ký học phần nào.'));
    }

    return ListView.builder(
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = enrollments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: ListTile(
            title: Text(
              enrollment.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lớp: ${enrollment.classCourse}'),
                Text('Giảng viên: ${enrollment.teacherName}'),
              ],
            ),
            onTap: () {
              // Điều hướng đến trang xem điểm chi tiết
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentScoreDetailScreen(
                    studentId: studentId,
                    hocphanId: enrollment.hocphanId, // Giả sử Enrollment có hocphanId
                    courseTitle: enrollment.title,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Hàm fetchCourses để làm mới danh sách học phần
  void _fetchCourses(WidgetRef ref) {
    ref.invalidate(enrolledCoursesProvider(studentId));
  }
}