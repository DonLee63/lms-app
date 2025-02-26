import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';

class StudentCoursesScreen extends ConsumerStatefulWidget {
  final int studentId;

  const StudentCoursesScreen({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends ConsumerState<StudentCoursesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Làm mới dữ liệu mỗi khi vào màn hình
    ref.refresh(enrolledCoursesProvider(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    final studentCoursesAsync = ref.watch(enrolledCoursesProvider(widget.studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách học phần'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(enrolledCoursesProvider(widget.studentId));
            },
          ),
        ],
      ),
      body: studentCoursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text('Không có học phần nào.'));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    course.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã học phần: ${course.courseCode}'),
                      Text('Số tín chỉ: ${course.tinchi}'),
                      Text('Lớp: ${course.classCourse}'),
                      Text('Trạng thái: ${course.status}'),
                    ],
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
