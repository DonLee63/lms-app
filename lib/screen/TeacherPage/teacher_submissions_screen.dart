import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    print('Assignment ID: ${widget.assignmentId}');
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
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final submissionsAsync = ref.watch(assignmentSubmissionsProvider(widget.assignmentId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Danh sách bài nộp'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(child: Text('Chưa có sinh viên nào nộp bài'));
          }

          print('Submissions: $submissions');
          print('First submission quizType: ${submissions.first.quizType}');

          final isTracNghiem = submissions.first.quizType == 'trac_nghiem';

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];

              if (submission.submissionId == null) {
                return const Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Bài nộp không hợp lệ: Thiếu submission ID'),
                  ),
                );
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.studentName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Thời gian nộp: ${submission.submittedAt ?? 'Không xác định'}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Điểm: ',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                          Text(
                            submission.score != null ? submission.score.toStringAsFixed(2) : 'Chưa chấm',
                            style: const TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                          const Spacer(),
                          if (!isTracNghiem) ...[
                            ElevatedButton(
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
                              child: const Text('Chấm điểm'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          if (error.toString().contains('404')) {
            return const Center(child: Text('Không tìm thấy bài tập. Vui lòng kiểm tra lại assignment ID.'));
          }
          return Center(child: Text('Lỗi: $error'));
        },
      ),
    );
  }
}