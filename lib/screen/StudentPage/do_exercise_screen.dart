import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/models/quiz.dart';
import 'package:study_management_app/providers/exercise_provider.dart';

class DoExerciseScreen extends ConsumerStatefulWidget {
  final StudentAssignment assignment;
  final int studentId;

  const DoExerciseScreen({super.key, required this.assignment, required this.studentId});

  @override
  ConsumerState<DoExerciseScreen> createState() => _DoExerciseScreenState();
}

class _DoExerciseScreenState extends ConsumerState<DoExerciseScreen> {
  late int remainingTime;
  Timer? timer;
  Map<int, int?> selectedAnswers = {}; // Trắc nghiệm
  Map<int, String> essayAnswers = {}; // Tự luận

  @override
  void initState() {
    super.initState();
    remainingTime = widget.assignment.time * 60;
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        timer.cancel();
        _submitQuiz(autoSubmit: true);
      }
    });
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    try {
      if (widget.assignment.quizType == 'trac_nghiem') {
        final answers = selectedAnswers.entries
            .where((entry) => entry.value != null)
            .map((entry) => {'question_id': entry.key, 'answer_id': entry.value!})
            .toList();

        if (answers.isEmpty && !autoSubmit) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng chọn ít nhất một đáp án!'), backgroundColor: Colors.red),
          );
          return;
        }

        await ref.read(exerciseRepositoryProvider).submitTracNghiemQuiz(
          widget.studentId,
          widget.assignment.assignmentId,
          answers,
        );
      } else {
        final answers = essayAnswers.entries
            .where((entry) => entry.value.isNotEmpty)
            .map((entry) => {'question_id': entry.key, 'content': entry.value})
            .toList();

        if (answers.isEmpty && !autoSubmit) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng nhập ít nhất một câu trả lời!'), backgroundColor: Colors.red),
          );
          return;
        }

        await ref.read(exerciseRepositoryProvider).submitTuLuanQuiz(
          widget.studentId,
          widget.assignment.assignmentId,
          answers,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(autoSubmit ? 'Hết thời gian, đã nộp bài!' : 'Nộp bài thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTracNghiem = widget.assignment.quizType == 'trac_nghiem';
    final questionsAsync = isTracNghiem
        ? ref.watch(tracNghiemQuestionsProvider(widget.assignment.assignmentId))
        : ref.watch(tuLuanQuestionsProvider(widget.assignment.assignmentId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Làm bài: ${widget.assignment.title}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Thời gian: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('Không có câu hỏi nào trong bài tập này'));
          }

          if (isTracNghiem && selectedAnswers.isEmpty) {
            selectedAnswers = {for (var q in questions) q.id: null};
          } else if (!isTracNghiem && essayAnswers.isEmpty) {
            essayAnswers = {for (var q in questions) q.id: ''};
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isTracNghiem
                            ? _buildTracNghiemQuestion(question, index)
                            : _buildTuLuanQuestion(question, index),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _submitQuiz(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Nộp bài', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildTracNghiemQuestion(QuizQuestion question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu ${index + 1}: ${question.content}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...question.answers!.map((answer) => RadioListTile<int>(
              title: Text(answer.content),
              value: answer.id,
              groupValue: selectedAnswers[question.id],
              onChanged: (value) {
                setState(() {
                  selectedAnswers[question.id] = value;
                });
              },
            )),
      ],
    );
  }

  Widget _buildTuLuanQuestion(QuizQuestion question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu ${index + 1}: ${question.content}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Nhập câu trả lời của bạn...',
          ),
          onChanged: (value) {
            essayAnswers[question.id] = value;
          },
        ),
      ],
    );
  }
}