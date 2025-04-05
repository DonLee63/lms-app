import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
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
  Map<int, int?> selectedAnswers = {};
  Map<int, String> essayAnswers = {};

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
            SnackBar(
              content: const Text('Vui lòng chọn ít nhất một đáp án!'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
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
            SnackBar(
              content: const Text('Vui lòng nhập ít nhất một câu trả lời!'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
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
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        );
        // Làm mới studentAssignmentsProvider để cập nhật trạng thái hasSubmitted
        ref.invalidate(studentAssignmentsProvider(widget.studentId));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: Text(
          'Làm bài: ${widget.assignment.title}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Thời gian: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 18,
                color: remainingTime <= 60 ? Colors.red : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Text(
                'Không có câu hỏi nào trong bài tập này',
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            );
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 600 + (index * 100)),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        elevation: 6.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                isDarkMode ? Colors.grey[800]! : Colors.blue[50]!,
                                isDarkMode ? Colors.grey[900]! : Colors.white,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: isTracNghiem
                                ? _buildTracNghiemQuestion(question, index)
                                : _buildTuLuanQuestion(question, index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ScaleTransitionButton(
                  onPressed: () => _submitQuiz(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[600]!,
                          Colors.blue[800]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Nộp bài',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: Colors.blue[800],
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Lỗi: $error',
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTracNghiemQuestion(QuizQuestion question, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu ${index + 1}: ${question.content}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.blue[900],
          ),
        ),
        const SizedBox(height: 12),
        ...question.answers!.asMap().entries.map((entry) {
          final answerIndex = entry.key;
          final answer = entry.value;
          return FadeInUp(
            duration: Duration(milliseconds: 600 + (answerIndex * 100)),
            child: RadioListTile<int>(
              title: Text(
                answer.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[200] : Colors.black,
                ),
              ),
              value: answer.id,
              groupValue: selectedAnswers[question.id],
              onChanged: (value) {
                setState(() {
                  selectedAnswers[question.id] = value;
                });
              },
              activeColor: Colors.blue[800],
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTuLuanQuestion(QuizQuestion question, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu ${index + 1}: ${question.content}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.blue[900],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
            hintText: 'Nhập câu trả lời của bạn...',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onChanged: (value) {
            essayAnswers[question.id] = value;
          },
        ),
      ],
    );
  }
}

class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ScaleTransitionButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _ScaleTransitionButtonState createState() => _ScaleTransitionButtonState();
}

class _ScaleTransitionButtonState extends State<ScaleTransitionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}