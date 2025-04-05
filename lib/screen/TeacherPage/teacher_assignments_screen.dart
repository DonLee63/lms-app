import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:study_management_app/models/quiz.dart';
import 'package:study_management_app/providers/exercise_provider.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_submissions_screen.dart';

class TeacherAssignmentsScreen extends ConsumerStatefulWidget {
  final int hocphanId;

  const TeacherAssignmentsScreen({super.key, required this.hocphanId});

  @override
  ConsumerState<TeacherAssignmentsScreen> createState() => _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState extends ConsumerState<TeacherAssignmentsScreen> {
  int? _userId;
  late Future<List<Assignment>> _assignmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
      _assignmentsFuture = ref.read(exerciseRepositoryProvider).getTeacherAssignments(_userId!, widget.hocphanId);
    });
  }

  Future<void> _assignQuiz(BuildContext context, Quiz quiz) async {
    DateTime? dueDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Giao bộ đề: ${quiz.title}", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bài tập sẽ được giao cho tất cả sinh viên trong học phần ${widget.hocphanId}.",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    dueDate != null
                        ? "Hạn nộp: ${DateFormat('dd/MM/yyyy HH:mm').format(dueDate!.toLocal())}"
                        : "Chọn hạn nộp",
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        dueDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        (context as Element).markNeedsBuild();
                      }
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text("Chọn"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (dueDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng chọn hạn nộp"), backgroundColor: Colors.red),
                );
                return;
              }

              final assignment = Assignment(
                quizId: quiz.id,
                quizType: quiz.type,
                hocphanId: widget.hocphanId,
                assignedAt: DateTime.now(),
              );

              try {
                final result = await ref.read(assignQuizProvider({
                  'assignment': assignment,
                  'userId': _userId!,
                }).future);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Giao bộ đề thành công cho học phần ${widget.hocphanId}!"),
                      backgroundColor: Colors.green[700],
                    ),
                  );
                  Navigator.pop(context);
                  setState(() {
                    _assignmentsFuture = ref.read(exerciseRepositoryProvider).getTeacherAssignments(_userId!, widget.hocphanId);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red[700]),
                  );
                }
              }
            },
            child: const Text("Giao", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAssignment(BuildContext context, Assignment assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác nhận xóa", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn xóa bài tập đã giao này?", style: TextStyle(color: Colors.grey[700])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(exerciseRepositoryProvider).deleteAssignment(_userId!, assignment.assignmentId!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Xóa bài tập thành công"), backgroundColor: Colors.green[700]),
        );
        setState(() {
          _assignmentsFuture = ref.read(exerciseRepositoryProvider).getTeacherAssignments(_userId!, widget.hocphanId);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_userId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: Text(
          "Bài tập đã giao - HP ${widget.hocphanId}",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh sách bài tập đã giao',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.blue[900],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Assignment>>(
                future: _assignmentsFuture,
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
                            'Lỗi: ${snapshot.error}',
                            style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }
                  final assignments = snapshot.data ?? [];
                  if (assignments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có bài tập nào được giao',
                            style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      return FadeInUp(
                        duration: Duration(milliseconds: 500 + (index * 100)),
                        child: Card(
                          elevation: 6.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: isDarkMode ? Colors.grey[850] : Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<List<Quiz>>(
                              future: ref.read(exerciseRepositoryProvider).getTeacherQuizzes(_userId!, widget.hocphanId),
                              builder: (context, quizSnapshot) {
                                if (quizSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final quizzes = quizSnapshot.data ?? [];
                                final quiz = quizzes.firstWhere(
                                  (q) => q.id == assignment.quizId,
                                  orElse: () => Quiz(
                                    id: assignment.quizId ?? 0,
                                    title: 'Không xác định',
                                    hocphanId: widget.hocphanId,
                                    totalPoints: 0,
                                    startTime: DateTime.now(),
                                    endTime: DateTime.now(),
                                    time: 0,
                                    type: assignment.quizType ?? 'Không xác định',
                                  ),
                                );
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            quiz.title,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode ? Colors.white : Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                        Chip(
                                          label: Text(
                                            quiz.type == 'trac_nghiem' ? 'Trắc nghiệm' : 'Tự luận',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: quiz.type == 'trac_nghiem' ? Colors.blue[700] : Colors.orange[700],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Giao lúc: ${assignment.assignedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(assignment.assignedAt!.toLocal()) : 'Chưa xác định'}',
                                      style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Bắt đầu: ${quiz.startTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(quiz.startTime!.toLocal()) : 'Chưa xác định'}',
                                      style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kết thúc: ${quiz.endTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(quiz.endTime!.toLocal()) : 'Chưa xác định'}',
                                      style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () => _assignQuiz(context, quiz),
                                          icon: Icon(Icons.assignment_add, color: Colors.blue[700]),
                                          tooltip: 'Giao lại',
                                        ),
                                        IconButton(
                                          onPressed: assignment.assignmentId != null
                                              ? () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => TeacherSubmissionsScreen(
                                                        assignmentId: assignment.assignmentId!,
                                                      ),
                                                    ),
                                                  )
                                              : null,
                                          icon: Icon(Icons.visibility, color: Colors.green[700]),
                                          tooltip: 'Xem điểm',
                                        ),
                                        IconButton(
                                          onPressed: assignment.assignmentId != null
                                              ? () => _deleteAssignment(context, assignment)
                                              : null,
                                          icon: Icon(Icons.delete, color: Colors.red[700]),
                                          tooltip: 'Xóa',
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}