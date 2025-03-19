import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_management_app/models/quiz.dart';
import 'package:study_management_app/providers/exercise_provider.dart';

class StudentExercisesScreen extends ConsumerStatefulWidget {
  final int studentId; // Nhận studentId qua constructor

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
          ref.refresh(studentAssignmentsProvider(widget.studentId)); // Làm mới dữ liệu
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
                          'Học phần ${hocphan.hocphanId}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...hocphan.assignments.map((assignment) => ListTile(
                              title: Text(assignment.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Loại: ${assignment.quizType == 'trac_nghiem' ? 'Trắc nghiệm' : 'Tự luận'}"),
                                  Text("Tổng điểm: ${assignment.totalPoints}"),
                                  Text("Thời gian: ${assignment.time} phút"),
                                  Text("Hạn nộp: ${DateFormat('dd/MM/yyyy HH:mm').format(assignment.dueDate)}"),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: assignment.dueDate.isBefore(DateTime.now())
                                    ? null // Vô hiệu hóa nếu quá hạn
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DoExerciseScreen(
                                              assignment: assignment,
                                            ),
                                          ),
                                        );
                                      },
                                child: const Text("Làm bài"),
                              ),
                            )),
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

class DoExerciseScreen extends StatelessWidget {
  final StudentAssignment assignment;

  const DoExerciseScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Làm bài: ${assignment.title}'),
      ),
      body: Center(
        child: Text(
          'Trang làm bài cho ${assignment.quizType} - ID: ${assignment.quizId}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}