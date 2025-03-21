import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_management_app/providers/exercise_provider.dart';
import 'package:study_management_app/screen/StudentPage/do_exercise_screen.dart';

class StudentExercisesScreen extends ConsumerStatefulWidget {
  final int studentId;

  const StudentExercisesScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentExercisesScreen> createState() => _StudentExercisesScreenState();
}

class _StudentExercisesScreenState extends ConsumerState<StudentExercisesScreen> {
  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(studentAssignmentsProvider(widget.studentId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Bài tập'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(studentAssignmentsProvider(widget.studentId));
        },
        child: assignmentsAsync.when(
          data: (hocphanAssignments) {
            if (hocphanAssignments.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có bài tập nào trong các học phần của bạn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: hocphanAssignments.length,
              itemBuilder: (context, index) {
                final hocphan = hocphanAssignments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hocphan.hocphanName, // Hiển thị tên học phần
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...hocphan.assignments.map((assignment) {
                          final now = DateTime.now();
                          final canDoExercise = assignment.startTime != null &&
                              assignment.endTime != null &&
                              now.isAfter(assignment.startTime!) &&
                              now.isBefore(assignment.endTime!) &&
                              now.isBefore(assignment.dueDate);

                          final statusText = assignment.startTime != null && now.isBefore(assignment.startTime!)
                              ? "Chưa đến giờ làm bài"
                              : (assignment.endTime != null && now.isAfter(assignment.endTime!)) ||
                                      now.isAfter(assignment.dueDate)
                                  ? "Đã hết thời gian làm bài"
                                  : "Có thể làm bài";

                          return ListTile(
                            title: Text(assignment.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Loại: ${assignment.quizType == 'trac_nghiem' ? 'Trắc nghiệm' : 'Tự luận'}"),
                                Text("Tổng điểm: ${assignment.totalPoints}"),
                                Text("Thời gian: ${assignment.time} phút"),
                                Text("Bắt đầu: ${assignment.startTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(assignment.startTime!) : 'Chưa xác định'}"),
                                Text("Kết thúc: ${assignment.endTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(assignment.endTime!) : 'Chưa xác định'}"),
                                Text("Hạn nộp: ${DateFormat('dd/MM/yyyy HH:mm').format(assignment.dueDate)}"),
                                Text("Trạng thái: $statusText"),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: canDoExercise
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DoExerciseScreen(
                                            assignment: assignment,
                                            studentId: widget.studentId,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text("Làm bài"),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Lỗi: $error',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}