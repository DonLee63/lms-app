import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/exercise_provider.dart';
import 'grade_submission_screen.dart';

class TeacherSubmissionsScreen extends ConsumerStatefulWidget {
  final int assignmentId;

  const TeacherSubmissionsScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  ConsumerState<TeacherSubmissionsScreen> createState() => _TeacherSubmissionsScreenState();
}

class _TeacherSubmissionsScreenState extends ConsumerState<TeacherSubmissionsScreen> {
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_userId == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
      );
    }

    final submissionsAsync = ref.watch(assignmentSubmissionsProvider(widget.assignmentId));

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Danh sách bài nộp',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 48,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có sinh viên nào nộp bài',
                    style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final isTracNghiem = submissions.first.quizType == 'trac_nghiem';

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              return FadeInUp(
                duration: Duration(milliseconds: 500 + (index * 100)),
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
                                submission.studentName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.blue[900],
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                isTracNghiem ? 'Trắc nghiệm' : 'Tự luận',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: isTracNghiem ? Colors.blue[700] : Colors.orange[700],
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thời gian nộp: ${submission.submittedAt ?? 'Không xác định'}',
                          style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Điểm: ',
                              style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                            ),
                            Text(
                              submission.score != null ? submission.score!.toStringAsFixed(2) : 'Chưa chấm',
                              style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                            ),
                            const Spacer(),
                            if (!isTracNghiem && submission.submissionId != null)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GradeSubmissionScreen(
                                        submission: submission,
                                        userId: _userId!,
                                        assignmentId: widget.assignmentId,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Chấm điểm'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                          ],
                        ),
                        if (submission.submissionId == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Bài nộp không hợp lệ: Thiếu submission ID',
                              style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
        error: (error, stack) => Center(
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
                error.toString().contains('404')
                    ? 'Không tìm thấy bài tập. Vui lòng kiểm tra lại assignment ID.'
                    : 'Lỗi: $error',
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}