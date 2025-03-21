import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late Future<List<Quiz>> _quizzesFuture;

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
      _quizzesFuture = ref.read(exerciseRepositoryProvider).getTeacherQuizzes(_userId!, widget.hocphanId);
    });
  }

  Future<void> _assignQuiz(BuildContext context, Quiz quiz) async {
    DateTime? dueDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Giao bộ đề: ${quiz.title}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Bài tập sẽ được giao cho tất cả sinh viên trong học phần."),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(dueDate != null
                      ? "Hạn nộp: ${DateFormat('dd/MM/yyyy HH:mm').format(dueDate!)}"
                      : "Chọn hạn nộp"),
                ),
                ElevatedButton(
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
                  child: const Text("Chọn"),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              if (dueDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng chọn hạn nộp")),
                );
                return;
              }

              final assignment = Assignment(
                quizId: quiz.id,
                quizType: quiz.type,
                hocphanId: widget.hocphanId,
                assignedAt: DateTime.now(),
                dueDate: dueDate!,
              );

              try {
                final result = await ref.read(assignQuizProvider({
                  'assignment': assignment,
                  'userId': _userId!,
                }).future);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Giao bộ đề thành công cho học phần ${widget.hocphanId}!")),
                  );
                  Navigator.pop(context);
                  setState(() {
                    _assignmentsFuture = ref.read(exerciseRepositoryProvider).getTeacherAssignments(_userId!, widget.hocphanId);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi: $e")),
                  );
                }
              }
            },
            child: const Text("Giao"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Bài tập đã giao - Học phần ${widget.hocphanId}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Danh sách bài tập đã giao",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Assignment>>(
                future: _assignmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  }
                  final assignments = snapshot.data ?? [];
                  if (assignments.isEmpty) {
                    return const Center(child: Text("Chưa có bài tập nào được giao trong học phần này"));
                  }
                  return FutureBuilder<List<Quiz>>(
                    future: _quizzesFuture,
                    builder: (context, quizSnapshot) {
                      if (quizSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (quizSnapshot.hasError) {
                        return Center(child: Text("Lỗi: ${quizSnapshot.error}"));
                      }
                      final quizzes = quizSnapshot.data ?? [];
                      return ListView.builder(
                        itemCount: assignments.length,
                        itemBuilder: (context, index) {
                          final assignment = assignments[index];
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
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                quiz.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Loại: ${assignment.quizType ?? 'Không xác định'}"),
                                  Text("Giao lúc: ${assignment.assignedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(assignment.assignedAt!) : 'Chưa xác định'}"),
                                  Text("Hạn nộp: ${assignment.dueDate != null ? DateFormat('dd/MM/yyyy HH:mm').format(assignment.dueDate!) : 'Chưa xác định'}"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _assignQuiz(context, quiz),
                                    child: const Text("Giao lại"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
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
                                    child: const Text("Xem điểm"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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