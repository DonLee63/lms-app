import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/models/enrollment.dart';
import 'package:study_management_app/providers/course_provider.dart';
import 'package:study_management_app/screen/StudentPage/student_teaching_content_screen.dart'; // Import màn hình tải tài liệu

class StudentEnrolledCourses extends ConsumerWidget {
  final int studentId;

  const StudentEnrolledCourses({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledCoursesAsync = ref.watch(enrolledCoursesProvider(studentId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Học phần đã đăng ký'),
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
              // Điều hướng đến trang tải tài liệu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentTeachingContentScreen(
                    studentId: studentId,
                    phancongId: enrollment.phancongId,
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