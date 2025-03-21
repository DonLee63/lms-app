import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/providers/exercise_provider.dart';

class TeacherSubmissionsScreen extends ConsumerWidget {
  final int assignmentId;

  const TeacherSubmissionsScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(assignmentSubmissionsProvider(assignmentId));

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

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    submission.studentName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Thời gian nộp: ${submission.submittedAt ?? 'Không xác định'}'),
                  trailing: Text(
                    'Điểm: ${submission.score is double ? submission.score.toStringAsFixed(2) : submission.score}',
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}