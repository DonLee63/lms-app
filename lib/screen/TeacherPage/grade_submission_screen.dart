import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/exercise_provider.dart';
import '../../models/quiz.dart';

class GradeSubmissionScreen extends ConsumerStatefulWidget {
  final Submission submission;
  final int userId;
  final int assignmentId;

  const GradeSubmissionScreen({
    super.key,
    required this.submission,
    required this.userId,
    required this.assignmentId,
  });

  @override
  ConsumerState<GradeSubmissionScreen> createState() => _GradeSubmissionScreenState();
}

class _GradeSubmissionScreenState extends ConsumerState<GradeSubmissionScreen> {
  late TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: widget.submission.score != null ? widget.submission.score!.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: Text(
          'Chấm điểm: ${widget.submission.studentName}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          overflow: TextOverflow.ellipsis,
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
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.person, color: Colors.blue[800], size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thời gian nộp: ${widget.submission.submittedAt ?? 'Không xác định'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Câu trả lời:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.blue[900],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.submission.answers == null || widget.submission.answers!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.question_answer_outlined,
                            size: 48,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có câu trả lời nào',
                            style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.submission.answers!.length,
                      itemBuilder: (context, index) {
                        final answer = widget.submission.answers![index];
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
                                  Text(
                                    'Câu hỏi ${index + 1}: ${answer.question}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Đáp án: ${answer.content}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Điểm: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _scoreController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Nhập điểm (0-10)',
                        hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final scoreText = _scoreController.text;
                      final score = double.tryParse(scoreText);
                      if (score == null || score < 0 || score > 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Vui lòng nhập điểm hợp lệ (0-10)'),
                            backgroundColor: Colors.red[700],
                          ),
                        );
                        return;
                      }

                      try {
                        await ref.read(updateSubmissionScoreProvider({
                          'userId': widget.userId,
                          'submissionId': widget.submission.submissionId!,
                          'score': score,
                        }).future);
                        ref.invalidate(assignmentSubmissionsProvider(widget.assignmentId));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Cập nhật điểm số thành công'),
                              backgroundColor: Colors.green[700],
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: Colors.red[700],
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Lưu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}