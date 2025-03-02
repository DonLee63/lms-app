import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/course_provider.dart';
import '../TeacherPage/teacher_attendance_screen.dart';

class CourseClassScreen extends ConsumerStatefulWidget {
  final int teacherId;
  final int phancongId; // Giữ nguyên phancongId

  const CourseClassScreen({
    super.key,
    required this.teacherId,
    required this.phancongId,
  });

  @override
  ConsumerState<CourseClassScreen> createState() => _CourseClassScreenState();
}

class _CourseClassScreenState extends ConsumerState<CourseClassScreen> {
  late final Future<List<Map<String, dynamic>>> studentsFuture;
  bool isExpanded = false; // Trạng thái mở rộng nút

  @override
  void initState() {
    super.initState();
    studentsFuture = ref.read(courseRepositoryProvider).getStudentsByTeacher(
          widget.teacherId,
          widget.phancongId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final teacherScheduleAsync = ref.watch(teacherScheduleProvider(widget.teacherId));

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách sinh viên")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error.toString()}"));
          }

          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(child: Text("Không có sinh viên nào."));
          }

          return ListView.separated(
            itemCount: students.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    student["student_name"].substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(student["student_name"]),
                subtitle: Text("${student["subject"]} - ${student["class_name"]}"),
                trailing: IconButton(
                  icon: const Icon(Icons.email, color: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Email: ${student["student_email"]}")),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: teacherScheduleAsync.when(
        data: (schedules) {
          final now = DateTime.now();
          final today = DateFormat('yyyy-MM-dd').format(now);
          final currentSession = now.hour >= 12 ? "Chiều" : "Sáng";

          // Lọc thời khóa biểu theo ngày, buổi và phancong_id
          final filteredSchedule = schedules.firstWhere(
            (schedule) =>
                schedule["ngay"] == today &&
                schedule["buoi"] == currentSession &&
                schedule["phancong_id"] == widget.phancongId, // Kiểm tra phancong_id
            orElse: () => null,
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isExpanded) ...[
                FloatingActionButton.extended(
                  heroTag: "attendance",
                  onPressed: filteredSchedule != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherAttendanceScreen(
                                tkbId: filteredSchedule["timetable_id"],
                              ),
                            ),
                          );
                        }
                      : null,
                  label: const Text("Điểm danh"),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  backgroundColor: filteredSchedule != null ? Colors.pink : Colors.grey,
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: "assignment",
                  onPressed: () {
                    // TODO: Thêm chức năng bài tập
                  },
                  label: const Text("Bài tập"),
                  icon: const Icon(Icons.assignment, color: Colors.white),
                  backgroundColor: Colors.pink,
                ),
                const SizedBox(height: 10),
              ],
              FloatingActionButton(
                heroTag: "main",
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Icon(isExpanded ? Icons.close : Icons.add, size: 32),
                backgroundColor: Colors.green,
              ),
            ],
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => FloatingActionButton(
          heroTag: "error",
          onPressed: () {},
          backgroundColor: Colors.red,
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}