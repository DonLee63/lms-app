import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
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
        return Colors.orange[700]!;
      case 'success':
        return Colors.green[700]!;
      case 'finished':
        return Colors.blue[700]!;
      case 'rejected':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'success':
        return 'Thành công';
      case 'finished':
        return 'Hoàn thành';
      case 'rejected':
        return 'Bị từ chối';
      default:
        return 'Không xác định';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.refresh(enrolledCoursesProvider(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_userRole == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
      );
    }

    final studentCoursesAsync = ref.watch(enrolledCoursesProvider(widget.studentId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Danh sách học phần',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(enrolledCoursesProvider(widget.studentId));
            },
            tooltip: 'Làm mới danh sách',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: studentCoursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 48,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có học phần nào',
                    style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return FadeInUp(
                duration: Duration(milliseconds: 500 + (index * 100)),
                child: Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.blue[900],
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                _getStatusText(course.status),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: _getStatusColor(course.status),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mã học phần: ${course.courseCode}',
                          style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Số tín chỉ: ${course.tinchi}',
                          style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lớp: ${course.classCourse}',
                          style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                        ),
                        if (_userRole == 'teacher') ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: course.status,
                            decoration: InputDecoration(
                              labelText: 'Cập nhật trạng thái',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Chờ xử lý'),
                              ),
                              DropdownMenuItem(
                                value: 'success',
                                child: Text('Thành công'),
                              ),
                              DropdownMenuItem(
                                value: 'finished',
                                child: Text('Hoàn thành'),
                              ),
                              DropdownMenuItem(
                                value: 'rejected',
                                child: Text('Bị từ chối'),
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
                                      SnackBar(
                                        content: const Text("Cập nhật trạng thái thành công"),
                                        backgroundColor: Colors.green[700],
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Lỗi: $e"),
                                        backgroundColor: Colors.red[700],
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: TextStyle(color: _getStatusColor(course.status)),
                            dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: isDarkMode ? Colors.red[300] : Colors.red[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi: $error',
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}