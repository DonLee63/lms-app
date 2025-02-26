import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/enrollment.dart';
import '../../providers/course_provider.dart';

class EnrolledCourseScreen extends ConsumerWidget {
  final int studentId;

  const EnrolledCourseScreen({super.key, required this.studentId});

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
          data: (enrollments) => Column(
            children: [
              // Tổng tín chỉ
              _buildTotalTinChi(enrollments),
              const Divider(),
              // Danh sách học phần
              Expanded(child: _buildCourseList(context, ref, enrollments)),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Lỗi: $error')),
        ),
      ),
    );
  }

  Widget _buildTotalTinChi(List<Enrollment> enrollments) {
    final totalTinChi = enrollments.fold<int>(0, (sum, enrollment) => sum + enrollment.tinchi);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tổng số tín chỉ:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '$totalTinChi tín chỉ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, WidgetRef ref, List<Enrollment> enrollments) {
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
                Text('Tín chỉ: ${enrollment.tinchi}'),
                Text('Lớp: ${enrollment.classCourse}'),
                Text('Giảng viên: ${enrollment.teacherName}'),
                Text('Trạng thái: ${enrollment.status}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmCancelEnrollment(context, ref, enrollment),
            ),
          ),
        );
      },
    );
  }

  void _confirmCancelEnrollment(BuildContext context, WidgetRef ref, Enrollment enrollment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hủy đăng ký'),
          content: Text('Bạn có chắc chắn muốn hủy đăng ký học phần "${enrollment.title}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _cancelEnrollment(context, ref, enrollment.enrollmentId);
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelEnrollment(BuildContext context, WidgetRef ref, int enrollmentId) async {
    try {
      final result = await ref.read(deleteEnrollmentProvider(enrollmentId).future);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.green),
        );
      }

      _fetchCourses(ref); // Gọi fetchCourse sau khi xóa
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Hàm fetchCourse để làm mới danh sách học phần
  void _fetchCourses(WidgetRef ref) {
    ref.invalidate(enrolledCoursesProvider(studentId));
  }
}
