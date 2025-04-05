import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart'; // Thêm thư viện animate_do
import '../../models/enrollment.dart';
import '../../providers/course_provider.dart';
import 'student_score_detail_screen.dart';
import 'student_progress_screen.dart';

class StudentScoresCourses extends ConsumerWidget {
  final int studentId;

  const StudentScoresCourses({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledCoursesAsync = ref.watch(enrolledCoursesProvider(studentId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: const Text(
          'Điểm học phần',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _fetchCourses(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchCourses(ref);
        },
        color: Colors.blue[800],
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        child: enrolledCoursesAsync.when(
          data: (enrollments) => _buildCourseList(context, enrollments, isDarkMode),
          loading: () => Center(
            child: CircularProgressIndicator(
              color: Colors.blue[800],
            ),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Lỗi: $error',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
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
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.trending_up),
        tooltip: 'Theo dõi tiến độ học tập',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCourseList(BuildContext context, List<Enrollment> enrollments, bool isDarkMode) {
    if (enrollments.isEmpty) {
      return Center(
        child: Text(
          'Bạn chưa đăng ký học phần nào.',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = enrollments[index];
        return FadeInUp(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            elevation: 6.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDarkMode ? Colors.grey[800]! : Colors.blue[50]!,
                    isDarkMode ? Colors.grey[900]! : Colors.white,
                  ],
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: Text(
                  enrollment.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blue[900],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lớp: ${enrollment.classCourse}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Giảng viên: ${enrollment.teacherName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode ? Colors.white : Colors.blue[800],
                  size: 20,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentScoreDetailScreen(
                        studentId: studentId,
                        hocphanId: enrollment.hocphanId,
                        courseTitle: enrollment.title,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _fetchCourses(WidgetRef ref) {
    ref.invalidate(enrolledCoursesProvider(studentId));
  }
}