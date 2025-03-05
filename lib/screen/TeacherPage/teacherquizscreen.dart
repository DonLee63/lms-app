import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/screen/TeacherPage/createquestionscreen.dart';
import 'package:study_management_app/screen/TeacherPage/createquizscreen.dart';

class TeacherQuizScreen extends ConsumerStatefulWidget {
  final int hocphanId;

  const TeacherQuizScreen({super.key, required this.hocphanId});

  @override
  ConsumerState<TeacherQuizScreen> createState() => _TeacherQuizScreenState();
}

class _TeacherQuizScreenState extends ConsumerState<TeacherQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo bài tập trắc nghiệm")),
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
              child: const Text("Tạo câu hỏi mới"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateQuizScreen(hocphanId: widget.hocphanId),
                ),
              ),
              child: const Text("Tạo đề thi mới"),
            ),
          ],
        ),
      ),
    );
  }
}