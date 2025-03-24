import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';

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
  String? _userRole;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role') ?? 'student';
      _userId = prefs.getInt('userId') ?? 1;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'finished':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.refresh(enrolledCoursesProvider(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListTile(
                    title: Text(
                      course.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Mã học phần: ${course.courseCode}'),
                        const SizedBox(height: 4),
                        Text('Số tín chỉ: ${course.tinchi}'),
                        const SizedBox(height: 4),
                        Text('Lớp: ${course.classCourse}'),
                        const SizedBox(height: 4),
                        // Hiển thị trạng thái
                        _userRole == 'teacher'
                            ? Row(
                                children: [
                                  const Text(
                                    'Trạng thái: ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: course.status,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'pending',
                                        child: Text('Chờ xử lý', style: TextStyle(color: Colors.orange)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'success',
                                        child: Text('Thành công', style: TextStyle(color: Colors.green)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'finished',
                                        child: Text('Hoàn thành', style: TextStyle(color: Colors.blue)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'rejected',
                                        child: Text('Bị từ chối', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                    onChanged: (newStatus) async {
                                      if (newStatus != null && newStatus != course.status) {
                                        try {
                                          await ref.read(updateEnrollmentStatusProvider({
                                            'userId': _userId!,
                                            'enrollmentId': course.enrollmentId,
                                            'newStatus': newStatus,
                                          }).future);
                                          ref.invalidate(enrolledCoursesProvider(widget.studentId));
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Cập nhật trạng thái thành công")),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Lỗi: $e")),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    style: TextStyle(
                                      color: _getStatusColor(course.status),
                                      fontSize: 14,
                                    ),
                                    dropdownColor: Colors.white,
                                    underline: Container(
                                      height: 1,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Text(
                                    'Trạng thái: ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    course.status == 'pending'
                                        ? 'Chờ xử lý'
                                        : course.status == 'success'
                                            ? 'Thành công'
                                            : course.status == 'finished'
                                                ? 'Hoàn thành'
                                                : 'Bị từ chối',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _getStatusColor(course.status),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
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