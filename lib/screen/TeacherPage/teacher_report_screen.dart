import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_course_report_screen.dart';
import '../../providers/course_provider.dart';

class TeacherReportScreen extends ConsumerWidget {
  final int teacherId;

  const TeacherReportScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(teacherReportProvider(teacherId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Thống kê và báo cáo'),
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
            onPressed: () {
              ref.invalidate(teacherReportProvider(teacherId));
            },
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          final totalCourses = (report['total_courses'] as num).toInt();
          final totalStudents = (report['total_students'] as num).toInt();
          final passRate = (report['pass_rate'] as num).toDouble();
          final averageScore = (report['average_score'] as num).toDouble();
          final courses = report['courses'] as List<dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thống kê tổng quan
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng quan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Số học phần:', style: TextStyle(fontSize: 16)),
                              Text(
                                totalCourses.toString(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tổng số sinh viên:', style: TextStyle(fontSize: 16)),
                              Text(
                                totalStudents.toString(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tỷ lệ đạt:', style: TextStyle(fontSize: 16)),
                              Text(
                                '${passRate.toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Điểm trung bình:', style: TextStyle(fontSize: 16)),
                              Text(
                                averageScore.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '(Điểm trung bình không bao gồm học phần điều kiện)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Danh sách học phần
                  const Text(
                    'Danh sách học phần',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (courses.isEmpty)
                    const Text('Chưa phụ trách học phần nào.'),
                  ...courses.map((course) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course['title'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (course['is_condition_course'] == 1) ...[
                                const Chip(
                                  label: Text(
                                    'Điều kiện',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tín chỉ: ${course['so_tin_chi']}'),
                              Text('Số sinh viên: ${course['total_students']}'),
                              Text('Tỷ lệ đạt: ${course['pass_rate'].toStringAsFixed(1)}%'),
                              Text('Điểm trung bình: ${course['average_score'].toStringAsFixed(2)}'),
                              if (course['is_condition_course'] == 1) ...[
                                const Text(
                                  '(Điểm trung bình không áp dụng cho học phần điều kiện)',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeacherCourseReportScreen(
                                  teacherId: teacherId,
                                  phancongId: course['phancong_id'],
                                  hocphanId: course['hocphan_id'],
                                  courseTitle: course['title'],
                                  students: course['students'],
                                  isConditionCourse: course['is_condition_course'] == 1,
                                  passRate: (course['pass_rate'] as num).toDouble(),
                                  averageScore: (course['average_score'] as num).toDouble(),
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}