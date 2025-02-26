import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';

class ExamScheduleScreen extends ConsumerWidget {
  final int studentId; // ID của sinh viên

  const ExamScheduleScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examScheduleAsync = ref.watch(examScheduleProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch Thi"),
      ),
      body: examScheduleAsync.when(
        data: (exams) {
          if (exams.isEmpty) {
            return const Center(
              child: Text("Không có lịch thi nào."),
            );
          }
          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    exam['subject'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Buổi thi: ${exam['buoi']}"),
                      Text("Ngày thi: ${exam['exam_date']}"),
                      if (exam['backup_exam_date'] != null)
                        Text("Ngày thi dự phòng: ${exam['backup_exam_date']}"),
                      Text("Lớp: ${exam['class_course']}"),
                      Text("Phòng thi: ${exam['location']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text("Lỗi khi tải dữ liệu: $err"),
        ),
      ),
    );
  }
}
