import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_management_app/screen/TeacherPage/teacherquizscreen.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_upload_content_screen.dart';
import '../../providers/course_provider.dart';
import '../TeacherPage/teacher_attendance_screen.dart';
import '../TeacherPage/student_average_scores_screen.dart'; // Import màn hình mới

class CourseClassScreen extends ConsumerStatefulWidget {
  final int teacherId;
  final int phancongId;

  const CourseClassScreen({
    super.key,
    required this.teacherId,
    required this.phancongId,
  });

  @override
  ConsumerState<CourseClassScreen> createState() => _CourseClassScreenState();
}

class _CourseClassScreenState extends ConsumerState<CourseClassScreen> {
  late Future<List<Map<String, dynamic>>> studentsFuture;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    studentsFuture = ref.read(courseRepositoryProvider).getStudentsByTeacher(
          widget.teacherId,
          widget.phancongId,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadStudents();
    });
    ref.invalidate(teacherScheduleProvider(widget.teacherId));
    await studentsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final teacherScheduleAsync = ref.watch(teacherScheduleProvider(widget.teacherId));

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách sinh viên")),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
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

            // Lấy hocphan_id từ danh sách sinh viên (giả sử tất cả sinh viên cùng hocphan_id)
            final hocphanId = students.isNotEmpty && students[0]["hocphan_id"] != null
                ? students[0]["hocphan_id"] as int
                : null;

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final student = students[index];
                final absentCount = student["absent_count"] as int? ?? 0;

                Color avatarColor;
                if (absentCount >= 3) {
                  avatarColor = Colors.red;
                } else if (absentCount == 2) {
                  avatarColor = Colors.orange;
                } else if (absentCount == 1) {
                  avatarColor = Colors.yellow;
                } else {
                  avatarColor = Colors.blueAccent;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: avatarColor,
                    child: Text(
                      student["student_name"].substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(student["student_name"]),
                  subtitle: Text("${student["subject"]} - ${student["class_name"]} - Vắng: $absentCount"),
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
      ),
      floatingActionButton: teacherScheduleAsync.when(
        data: (schedules) {
          final now = DateTime.now();
          final today = DateFormat('yyyy-MM-dd').format(now);
          String currentSession;

          if (now.hour < 12) {
            currentSession = "Sáng";
          } else if (now.hour < 18) {
            currentSession = "Chiều";
          } else {
            currentSession = "Tối";
          }

          // Lọc lịch dạy hôm nay cho điểm danh
          final filteredSchedule = schedules.firstWhere(
            (schedule) =>
                schedule["ngay"] == today &&
                schedule["buoi"] == currentSession &&
                schedule["phancong_id"] == widget.phancongId,
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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: studentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    final students = snapshot.data ?? [];
                    final hocphanId = students.isNotEmpty && students[0]["hocphan_id"] != null
                        ? students[0]["hocphan_id"] as int
                        : null;

                    return Column(
                      children: [
                        FloatingActionButton.extended(
                          heroTag: "assignment",
                          onPressed: hocphanId != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeacherQuizScreen(
                                        hocphanId: hocphanId,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          label: const Text("Bài tập"),
                          icon: const Icon(Icons.assignment, color: Colors.white),
                          backgroundColor: hocphanId != null ? Colors.pink : Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton.extended(
                          heroTag: "average_scores",
                          onPressed: hocphanId != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentAverageScoresScreen(
                                        hocphanId: hocphanId,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          label: const Text("Xem điểm trung bình"),
                          icon: const Icon(Icons.score, color: Colors.white),
                          backgroundColor: hocphanId != null ? Colors.purple : Colors.grey,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: "upload_content",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherUploadContentScreen(
                          teacherId: widget.teacherId,
                          phancongId: widget.phancongId,
                        ),
                      ),
                    );
                  },
                  label: const Text("Tải lên tài liệu"),
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  backgroundColor: Colors.blue,
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