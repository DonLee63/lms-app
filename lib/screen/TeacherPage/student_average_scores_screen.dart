import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/exercise_provider.dart';

class StudentAverageScoresScreen extends ConsumerWidget {
  final int hocphanId;

  const StudentAverageScoresScreen({
    super.key,
    required this.hocphanId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averageScoresAsync = ref.watch(studentAverageScoresProvider(hocphanId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Điểm trung bình sinh viên'),
      ),
      body: averageScoresAsync.when(
        data: (data) {
          if (!data['success']) {
            return Center(child: Text(data['message']));
          }

          final hocphanData = data['data'];
          final students = (hocphanData['students'] as List<dynamic>)
              .map((student) => student as Map<String, dynamic>)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Học phần ID: ${hocphanData['hocphan_id']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Danh sách sinh viên:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final averageScore = student['average_score'] ?? 0; // Nếu null thì hiển thị 0
                      final submissions = (student['submissions'] as List<dynamic>)
                          .map((submission) => submission as Map<String, dynamic>)
                          .toList();

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sinh viên: ${student['student_name']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mã sinh viên: ${student['mssv']}', // Thay student_id bằng mssv
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Điểm trung bình: $averageScore',
                                style: const TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                              if (submissions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Danh sách bài nộp:',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                ...submissions.map((submission) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Bài tập: ${submission['assignment_title']}', // Thay assignment_id bằng assignment_title
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'Điểm: ${submission['score']}',
                                          style: const TextStyle(fontSize: 14, color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}