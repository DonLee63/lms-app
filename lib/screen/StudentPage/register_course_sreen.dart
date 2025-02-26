import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';
import '../../router.dart';
// import 'enrolled_course_screen.dart';

class RegisterCourseScreen extends ConsumerStatefulWidget {
  final int studentId;

  const RegisterCourseScreen({super.key, required this.studentId});

  @override
  ConsumerState<RegisterCourseScreen> createState() => _RegisterCourseScreenState();
}

class _RegisterCourseScreenState extends ConsumerState<RegisterCourseScreen> {
  String searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(groupedCoursesProvider(widget.studentId)); // Làm mới dữ liệu
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedCoursesAsync = ref.watch(groupedCoursesProvider(widget.studentId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Đăng ký học phần'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.enroll, arguments: widget.studentId);
        },
        child: const Icon(Icons.list_alt),
        tooltip: 'Học phần đã đăng ký',
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCourses,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ô tìm kiếm
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm học phần...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Danh sách học phần
              Expanded(
                child: groupedCoursesAsync.when(
                  data: (groupedCourses) {
                    // Lọc dữ liệu theo searchQuery
                    final filteredCourses = _filterGroupedCourses(groupedCourses);
                    return _buildGroupedCourseList(filteredCourses);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text("Lỗi: $error")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Map<String, List<Course>>> _filterGroupedCourses(Map<String, Map<String, List<Course>>> groupedCourses) {
    if (searchQuery.isEmpty) {
      return groupedCourses;
    }

    final filteredCourses = <String, Map<String, List<Course>>>{};

    groupedCourses.forEach((hocKy, categories) {
      final filteredBatBuoc = categories['bat_buoc']?.where((course) {
        return course.title.toLowerCase().contains(searchQuery) || course.classCourse.toLowerCase().contains(searchQuery);
      }).toList();

      final filteredTuChon = categories['tu_chon']?.where((course) {
        return course.title.toLowerCase().contains(searchQuery) || course.classCourse.toLowerCase().contains(searchQuery);
      }).toList();

      if ((filteredBatBuoc?.isNotEmpty ?? false) || (filteredTuChon?.isNotEmpty ?? false)) {
        filteredCourses[hocKy] = {
          'bat_buoc': filteredBatBuoc ?? [],
          'tu_chon': filteredTuChon ?? [],
        };
      }
    });

    return filteredCourses;
  }

  Widget _buildGroupedCourseList(Map<String, Map<String, List<Course>>> groupedCourses) {
    if (groupedCourses.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy học phần nào.'),
      );
    }

    return ListView(
      children: groupedCourses.entries.map((entry) {
        final hocKy = entry.key;
        final batBuocCourses = entry.value['bat_buoc'] ?? [];
        final tuChonCourses = entry.value['tu_chon'] ?? [];

        return ExpansionTile(
          title: Text('Học kỳ $hocKy', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          children: [
            _buildCourseCategory('Bắt buộc', batBuocCourses),
            _buildCourseCategory('Tự chọn', tuChonCourses),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCourseCategory(String category, List<Course> courses) {
    if (courses.isEmpty) {
      return ListTile(
        title: Text('Không có học phần $category.', style: const TextStyle(fontStyle: FontStyle.italic)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Text(
            category,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        ...courses.map((course) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                'Tên HP: ${course.title}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lớp: ${course.classCourse}'),
                  Text('Giảng viên: ${course.teacherName}'),
                  Text('Số tín chỉ: ${course.tinchi}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _onCourseTap(course);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  void _onCourseTap(Course course) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận đăng ký'),
          content: Text('Bạn có chắc chắn muốn đăng ký học phần "${course.title}" không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _enrollCourse(course);
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enrollCourse(Course course) async {
    try {
      final result = await ref.read(courseEnrollmentProvider({
        'student_id': widget.studentId,
        'phancong_id': course.phancongId,
      }).future);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
        ),
      );

      _fetchCourses();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
