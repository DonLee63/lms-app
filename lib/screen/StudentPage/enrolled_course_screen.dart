import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/enrollment.dart';
import '../../providers/course_provider.dart';

class EnrolledCourseScreen extends ConsumerWidget {
  final int studentId;

  const EnrolledCourseScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledCoursesAsync = ref.watch(enrolledCoursesProvider(studentId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: const Text(
          'Học phần đã đăng ký',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _fetchCourses(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchCourses(ref);
        },
        color: Colors.blue[800],
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        child: enrolledCoursesAsync.when(
          data: (enrollments) => Column(
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: _buildTotalTinChi(context, enrollments),
              ),
              Divider(
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                thickness: 1.0,
              ),
              Expanded(child: _buildCourseList(context, ref, enrollments)),
            ],
          ),
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
    );
  }

  Widget _buildTotalTinChi(BuildContext context, List<Enrollment> enrollments) {
    final totalTinChi = enrollments.fold<int>(0, (sum, enrollment) => sum + enrollment.tinchi);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng số tín chỉ:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            '$totalTinChi tín chỉ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, WidgetRef ref, List<Enrollment> enrollments) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (enrollments.isEmpty) {
      return Center(
        child: Text(
          'Bạn chưa đăng ký học phần nào.',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = enrollments[index];
        return FadeInUp(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            elevation: 6.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDarkMode ? Colors.grey[800]! : Colors.blue[50]!,
                    isDarkMode ? Colors.grey[900]! : Colors.white,
                  ],
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: Text(
                  enrollment.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blue[900],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tín chỉ: ${enrollment.tinchi}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Lớp: ${enrollment.classCourse}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Giảng viên: ${enrollment.teacherName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Trạng thái: ${enrollment.status}',
                      style: TextStyle(
                        fontSize: 14,
                        color: enrollment.status == 'success'
                            ? Colors.green
                            : (enrollment.status == 'pending'
                                ? Colors.orange
                                : (enrollment.status == 'finished'
                                    ? Colors.blue
                                    : Colors.red)),
                      ),
                    ),
                  ],
                ),
                trailing: ScaleTransitionButton(
                  onPressed: () => _checkAndConfirmCancelEnrollment(context, ref, enrollment),
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _hasTimetableForCourse(WidgetRef ref, Enrollment enrollment) async {
    try {
      final timetable = await ref.watch(timetableProvider(studentId).future);
      return timetable.any((item) =>
          item['class_course'] == enrollment.classCourse || item['title'] == enrollment.title);
    } catch (e) {
      return false;
    }
  }

  void _checkAndConfirmCancelEnrollment(BuildContext context, WidgetRef ref, Enrollment enrollment) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Kiểm tra trạng thái và thời khóa biểu
    final hasTimetable = await _hasTimetableForCourse(ref, enrollment);
    final canCancel = enrollment.status == 'pending' && !hasTimetable;

    if (!canCancel) {
      String message;
      if (enrollment.status == 'success' && hasTimetable) {
        message = 'Học phần "${enrollment.title}" đã được xác nhận (success) và đã có thời khóa biểu, không thể hủy.';
      } else if (enrollment.status == 'success') {
        message = 'Học phần "${enrollment.title}" đã được xác nhận (success), không thể hủy.';
      } else if (hasTimetable) {
        message = 'Học phần "${enrollment.title}" đã có thời khóa biểu, không thể hủy.';
      } else {
        message = 'Học phần "${enrollment.title}" không thể hủy do trạng thái không phù hợp.';
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            title: Text(
              'Không thể hủy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            content: Text(
              message,
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
                    'Đóng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'Hủy đăng ký',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn hủy đăng ký học phần "${enrollment.title}" không?',
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
                await _cancelEnrollment(context, ref, enrollment.enrollmentId);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red[600]!,
                      Colors.red[800]!,
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

  Future<void> _cancelEnrollment(BuildContext context, WidgetRef ref, int enrollmentId) async {
    try {
      final result = await ref.read(deleteEnrollmentProvider(enrollmentId).future);

      if (context.mounted) {
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
      }

      _fetchCourses(ref);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $error'),
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

  void _fetchCourses(WidgetRef ref) {
    ref.invalidate(enrolledCoursesProvider(studentId));
  }
}

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