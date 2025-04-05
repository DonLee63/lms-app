import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart'; // Thêm thư viện animate_do để tạo animation
import '../../providers/course_provider.dart';
import '../../models/course.dart';
import '../../router.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ Dark Mode

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Màu xanh đậm chuyên nghiệp
        elevation: 0,
        title: const Text(
          'Đăng ký học phần',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Màu chữ trắng để luôn dễ đọc
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.enroll, arguments: widget.studentId);
        },
        child: const Icon(Icons.list_alt, color: Colors.white),
        tooltip: 'Học phần đã đăng ký',
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCourses,
        color: Colors.blue[800], // Màu của vòng xoay làm mới
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white, // Điều chỉnh màu nền của RefreshIndicator
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ô tìm kiếm
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm học phần...',
                      prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Danh sách học phần
              Expanded(
                child: groupedCoursesAsync.when(
                  data: (groupedCourses) {
                    // Lọc dữ liệu theo searchQuery
                    final filteredCourses = _filterGroupedCourses(groupedCourses);
                    return _buildGroupedCourseList(filteredCourses);
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue[800],
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Lỗi: $error',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (groupedCourses.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy học phần nào.',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: groupedCourses.length,
      itemBuilder: (context, index) {
        final entry = groupedCourses.entries.elementAt(index);
        final hocKy = entry.key;
        final batBuocCourses = entry.value['bat_buoc'] ?? [];
        final tuChonCourses = entry.value['tu_chon'] ?? [];

        return FadeInUp(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            elevation: 6.0,
            child: ExpansionTile(
              leading: Icon(
                Icons.book,
                color: Colors.blue[800],
              ),
              title: Text(
                'Học kỳ $hocKy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue[900],
                ),
              ),
              children: [
                _buildCourseCategory('Bắt buộc', batBuocCourses),
                _buildCourseCategory('Tự chọn', tuChonCourses),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseCategory(String category, List<Course> courses) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (courses.isEmpty) {
      return ListTile(
        title: Text(
          'Không có học phần $category.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[800],
            ),
          ),
        ),
        ...courses.asMap().entries.map((entry) {
          final index = entry.key;
          final course = entry.value;
          return FadeInUp(
            duration: Duration(milliseconds: 600 + (index * 100)),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              elevation: 4.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDarkMode ? Colors.grey[800]! : Colors.blue[50]!, // Gradient điều chỉnh theo chế độ
                      isDarkMode ? Colors.grey[900]! : Colors.white,
                    ],
                  ),
                ),
                child: ScaleTransitionButton(
                  onPressed: () => _onCourseTap(course),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(
                      'Tên HP: ${course.title}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lớp: ${course.classCourse}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Giảng viên: ${course.teacherName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Số tín chỉ: ${course.tinchi}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _onCourseTap(Course course) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'Xác nhận đăng ký',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng ký học phần "${course.title}" không?',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          actions: [
            ScaleTransitionButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            ScaleTransitionButton(
              onPressed: () async {
                Navigator.pop(context);
                await _enrollCourse(course);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[600]!,
                      Colors.blue[800]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Đồng ý',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
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
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );

      _fetchCourses();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    }
  }
}

// Widget tùy chỉnh để thêm hiệu ứng scale khi nhấn
class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ScaleTransitionButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _ScaleTransitionButtonState createState() => _ScaleTransitionButtonState();
}

class _ScaleTransitionButtonState extends State<ScaleTransitionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}