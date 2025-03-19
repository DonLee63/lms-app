import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/models/quiz.dart';
import 'package:study_management_app/providers/exercise_provider.dart';
import 'package:study_management_app/screen/TeacherPage/createquestionscreen.dart';
import 'package:study_management_app/screen/TeacherPage/createquizscreen.dart';
import 'package:study_management_app/screen/TeacherPage/createessayquestionscreen.dart';
import 'package:study_management_app/screen/TeacherPage/createessayquizscreen.dart';

class TeacherQuizScreen extends ConsumerStatefulWidget {
  final int hocphanId;

  const TeacherQuizScreen({super.key, required this.hocphanId});

  @override
  ConsumerState<TeacherQuizScreen> createState() => _TeacherQuizScreenState();
}

class _TeacherQuizScreenState extends ConsumerState<TeacherQuizScreen> {
  int? _userId;
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
      // Chỉ khởi tạo Future một lần khi _userId có giá trị
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
                  // Refresh danh sách bộ đề sau khi giao bài (nếu cần)
                  setState(() {
                    _quizzesFuture = ref.read(exerciseRepositoryProvider).getTeacherQuizzes(_userId!, widget.hocphanId);
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
      appBar: AppBar(title: Text("Quản lý bài tập - Học phần ${widget.hocphanId}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateQuestionScreen(hocphanId: widget.hocphanId),
                ),
              ),
              child: const Text("Tạo câu hỏi trắc nghiệm mới"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateQuizScreen(hocphanId: widget.hocphanId),
                ),
              ),
              child: const Text("Tạo đề thi trắc nghiệm mới"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEssayQuestionScreen(hocphanId: widget.hocphanId),
                ),
              ),
              child: const Text("Tạo câu hỏi tự luận mới"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEssayQuizScreen(hocphanId: widget.hocphanId),
                ),
              ),
              child: const Text("Tạo bộ đề tự luận mới"),
            ),
            const SizedBox(height: 24),
            const Text(
              "Danh sách bộ đề",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Quiz>>(
                future: _quizzesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  }
                  final quizzes = snapshot.data ?? [];
                  if (quizzes.isEmpty) {
                    return const Center(child: Text("Chưa có bộ đề nào trong học phần này"));
                  }
                  return ListView.builder(
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
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
                              Text("Loại: ${quiz.type == 'trac_nghiem' ? 'Trắc nghiệm' : 'Tự luận'}"),
                              Text("Tổng điểm: ${quiz.totalPoints}"),
                              Text("Thời gian: ${quiz.time} phút"),
                              Text("Bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm').format(quiz.startTime)}"),
                              Text("Kết thúc: ${DateFormat('dd/MM/yyyy HH:mm').format(quiz.endTime)}"),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _assignQuiz(context, quiz),
                            child: const Text("Giao bài"),
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