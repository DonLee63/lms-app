import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:study_management_app/screen/TeacherPage/teacherquizscreen.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_upload_content_screen.dart';
import '../../providers/course_provider.dart';
import '../TeacherPage/teacher_attendance_screen.dart';
import '../TeacherPage/student_average_scores_screen.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Danh sách sinh viên',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refresh,
            tooltip: 'Làm mới',
          ),
        ],
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.blue[700],
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: isDarkMode ? Colors.red[300] : Colors.red[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${snapshot.error.toString()}',
                      style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            final students = snapshot.data ?? [];
            if (students.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt,
                      size: 48,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có sinh viên nào',
                      style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            final hocphanId = students.isNotEmpty && students[0]["hocphan_id"] != null
                ? students[0]["hocphan_id"] as int
                : null;

            return ListView.separated(
              padding: const EdgeInsets.all(12.0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final student = students[index];
                final absentCount = student["absent_count"] as int? ?? 0;

                Color avatarColor;
                if (absentCount >= 3) {
                  avatarColor = Colors.red[700]!;
                } else if (absentCount == 2) {
                  avatarColor = Colors.orange[700]!;
                } else if (absentCount == 1) {
                  avatarColor = Colors.yellow[700]!;
                } else {
                  avatarColor = Colors.blue[700]!;
                }

                return FadeInUp(
                  duration: Duration(milliseconds: 500 + (index * 100)),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      leading: CircleAvatar(
                        backgroundColor: avatarColor,
                        radius: 24,
                        child: Text(
                          student["student_name"].substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        student["student_name"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blue[900],
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "${student["subject"]} - ${student["class_name"]} - Vắng: $absentCount",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.email, color: Colors.blue[700]),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Email: ${student["student_email"]}"),
                              backgroundColor: Colors.blue[700],
                            ),
                          );
                        },
                        tooltip: 'Xem email',
                      ),
                    ),
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

          final filteredSchedule = schedules.firstWhere(
            (schedule) =>
                schedule["ngay"] == today &&
                schedule["buoi"] == currentSession &&
                schedule["phancong_id"] == widget.phancongId,
            orElse: () => {},
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isExpanded) ...[
                FloatingActionButton.extended(
                  heroTag: "attendance",
                  onPressed: filteredSchedule.isNotEmpty
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
                  backgroundColor: filteredSchedule.isNotEmpty ? Colors.pink[700] : Colors.grey[600],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 12),
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
                          backgroundColor: hocphanId != null ? Colors.pink[700] : Colors.grey[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        const SizedBox(height: 12),
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
                          backgroundColor: hocphanId != null ? Colors.purple[700] : Colors.grey[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
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
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 12),
              ],
              FloatingActionButton(
                heroTag: "main",
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Icon(isExpanded ? Icons.close : Icons.add, size: 32),
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ],
          );
        },
        loading: () => CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
        ),
        error: (err, stack) => FloatingActionButton(
          heroTag: "error",
          onPressed: () {},
          backgroundColor: Colors.red[700],
          child: const Icon(Icons.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}