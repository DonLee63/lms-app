import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:study_management_app/models/quiz.dart';
import 'package:study_management_app/providers/exercise_provider.dart';
import 'package:study_management_app/screen/TeacherPage/createquestionscreen.dart';
import 'package:study_management_app/screen/TeacherPage/createquizscreen.dart';
import 'package:study_management_app/screen/TeacherPage/createessayquestionscreen.dart';
import 'package:study_management_app/screen/TeacherPage/createessayquizscreen.dart';
import 'package:study_management_app/screen/TeacherPage/edit_essay_quiz_screen.dart';
import 'package:study_management_app/screen/TeacherPage/editquizscreen.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_assignments_screen.dart';
// import 'package:study_management_app/screen/TeacherPage/edit_quiz_screen.dart'; // Import EditQuizScreen

class TeacherQuizScreen extends ConsumerStatefulWidget {
  final int hocphanId;

  const TeacherQuizScreen({super.key, required this.hocphanId});

  @override
  ConsumerState<TeacherQuizScreen> createState() => _TeacherQuizScreenState();
}

class _TeacherQuizScreenState extends ConsumerState<TeacherQuizScreen> {
  int? _userId;
  late Future<List<Quiz>> _quizzesFuture;
  bool _isActionsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
      _quizzesFuture = ref.read(exerciseRepositoryProvider).getTeacherQuizzes(_userId!, widget.hocphanId);
    });
  }

  Future<void> _assignQuiz(BuildContext context, Quiz quiz) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Giao bộ đề: ${quiz.title}", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          "Bài tập sẽ được giao cho tất cả sinh viên trong học phần.\nHạn nộp: ${DateFormat('dd/MM/yyyy HH:mm').format(quiz.endTime.toLocal())}",
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Giao", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

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
          SnackBar(content: Text("Giao bộ đề thành công!"), backgroundColor: Colors.green[700]),
        );
        setState(() {
          _quizzesFuture = ref.read(exerciseRepositoryProvider).getTeacherQuizzes(_userId!, widget.hocphanId);
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

  Future<void> _deleteQuiz(BuildContext context, Quiz quiz) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác nhận xóa", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn xóa bộ đề '${quiz.title}'?", style: TextStyle(color: Colors.grey[700])),
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
      await ref.read(exerciseRepositoryProvider).deleteQuiz(_userId!, quiz.id, quiz.type);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xóa bộ đề thành công"), backgroundColor: Colors.green[700]),
        );
        setState(() {
          _quizzesFuture = ref.read(exerciseRepositoryProvider).getTeacherQuizzes(_userId!, widget.hocphanId);
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          "Quản lý bài tập",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isActionsExpanded ? Icons.close : Icons.add, color: Colors.white),
            onPressed: () {
              setState(() {
                _isActionsExpanded = !_isActionsExpanded;
              });
            },
            tooltip: 'Tùy chọn tạo',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isActionsExpanded) ...[
              FadeInDown(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo mới',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context: context,
                          label: "Câu hỏi trắc nghiệm",
                          icon: Icons.question_answer,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreateQuestionScreen(hocphanId: widget.hocphanId)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context: context,
                          label: "Đề trắc nghiệm",
                          icon: Icons.quiz,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreateQuizScreen(hocphanId: widget.hocphanId)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context: context,
                          label: "Câu hỏi tự luận",
                          icon: Icons.edit,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreateEssayQuestionScreen(hocphanId: widget.hocphanId)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context: context,
                          label: "Đề tự luận",
                          icon: Icons.article,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreateEssayQuizScreen(hocphanId: widget.hocphanId)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Danh sách bộ đề',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.blue[900],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Quiz>>(
                future: _quizzesFuture,
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
                  final quizzes = snapshot.data ?? [];
                  if (quizzes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.quiz,
                            size: 48,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có bộ đề nào',
                            style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: quizzes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: Card(
                            elevation: 6.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: Icon(Icons.assignment_turned_in, color: Colors.green[700]),
                              title: Text(
                                'Xem bài tập đã giao',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.green[900],
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TeacherAssignmentsScreen(hocphanId: widget.hocphanId)),
                              ),
                            ),
                          ),
                        );
                      }
                      final quiz = quizzes[index - 1];
                      return FadeInUp(
                        duration: Duration(milliseconds: 500 + ((index - 1) * 100)),
                        child: Card(
                          elevation: 6.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: isDarkMode ? Colors.grey[850] : Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
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
                                Row(
                                  children: [
                                    Icon(Icons.score, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tổng điểm: ${quiz.totalPoints}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Thời gian: ${quiz.time} phút',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Bắt đầu: ${quiz.startTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(quiz.startTime.toLocal()) : 'Chưa xác định'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.event_busy, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Kết thúc: ${quiz.endTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(quiz.endTime.toLocal()) : 'Chưa xác định'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        if (quiz.type == 'trac_nghiem') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditQuizScreen(
                                                quizId: quiz.id,
                                                hocphanId: widget.hocphanId,
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Uncomment if EditEssayQuizScreen is created:
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditEssayQuizScreen(
                                                quizId: quiz.id,
                                                hocphanId: widget.hocphanId,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text("Sửa"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[700],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 4.0,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _assignQuiz(context, quiz),
                                      icon: const Icon(Icons.send, size: 18),
                                      label: const Text("Giao"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[700],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 4.0,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _deleteQuiz(context, quiz),
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text("Xóa"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[700],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 4.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 50),
        elevation: 4.0,
      ),
    );
  }
}