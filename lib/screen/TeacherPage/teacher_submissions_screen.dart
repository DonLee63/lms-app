import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/exercise_provider.dart';
import '../../models/quiz.dart'; // Import Submission từ quiz.dart

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
  final Map<int, TextEditingController> _scoreControllers = {};

  @override
  void initState() {
    super.initState();
    print('Assignment ID: ${widget.assignmentId}'); // Debug assignmentId
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
    });
  }

  @override
  void dispose() {
    _scoreControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
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

          final isTracNghiem = submissions.first.quizType == 'trac_nghiem';

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];

              // Kiểm tra submissionId trước khi sử dụng
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

              if (!isTracNghiem && !_scoreControllers.containsKey(submission.submissionId)) {
                _scoreControllers[submission.submissionId!] = TextEditingController(
                  text: submission.score != null ? submission.score.toStringAsFixed(2) : '',
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
                      if (!isTracNghiem && submission.answers != null) ...[
                        const Text(
                          'Câu trả lời:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          submission.answers!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          const Text(
                            'Điểm: ',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                          if (isTracNghiem)
                            Text(
                              submission.score != null ? submission.score.toStringAsFixed(2) : 'Chưa chấm',
                              style: const TextStyle(fontSize: 16, color: Colors.blue),
                            )
                          else ...[
                            Expanded(
                              child: TextField(
                                controller: _scoreControllers[submission.submissionId!],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Nhập điểm (0-10)',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final scoreText = _scoreControllers[submission.submissionId!]!.text;
                                final score = double.tryParse(scoreText);
                                if (score == null || score < 0 || score > 10) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập điểm hợp lệ (0-10)')),
                                  );
                                  return;
                                }

                                try {
                                  await ref.read(updateSubmissionScoreProvider({
                                    'userId': _userId!,
                                    'submissionId': submission.submissionId!,
                                    'score': score,
                                  }).future);
                                  ref.invalidate(assignmentSubmissionsProvider(widget.assignmentId));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Cập nhật điểm số thành công')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Lỗi: $e')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Lưu'),
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