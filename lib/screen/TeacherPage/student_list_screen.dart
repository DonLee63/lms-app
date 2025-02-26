import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';
import 'student_course_screen.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  final int teacherId;

  const StudentListScreen({super.key, required this.teacherId});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Làm mới danh sách sinh viên khi vào màn hình
    ref.refresh(classStudentsProvider(widget.teacherId));
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(classStudentsProvider(widget.teacherId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sinh viên'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(classStudentsProvider(widget.teacherId));
            },
          ),
        ],
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('Không có sinh viên nào.'));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                elevation: 4.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      student.studentName[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    student.studentName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4.0),
                      Text('MSSV: ${student.mssv}'),
                      Text('Lớp: ${student.className}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info, color: Colors.blue),
                    onPressed: () {
                      // Điều hướng tới màn hình StudentCoursesScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentCoursesScreen(studentId: student.studentId),
                        ),
                      );
                    },
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
