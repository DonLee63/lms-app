import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../providers/exercise_provider.dart';
import 'do_exercise_screen.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: const Text(
          'Bài tập',
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
            onPressed: () => ref.invalidate(studentAssignmentsProvider(widget.studentId)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(studentAssignmentsProvider(widget.studentId));
        },
        color: Colors.blue[800],
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        child: assignmentsAsync.when(
          data: (hocphanAssignments) {
            if (hocphanAssignments.isEmpty) {
              return Center(
                child: Text(
                  'Chưa có bài tập nào trong các học phần của bạn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: hocphanAssignments.length,
              itemBuilder: (context, index) {
                final hocphan = hocphanAssignments[index];
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hocphan.hocphanName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...hocphan.assignments.asMap().entries.map((entry) {
                              final assignmentIndex = entry.key;
                              final assignment = entry.value;
                              final now = DateTime.now();
                              final canDoExercise = !assignment.hasSubmitted &&
                                  assignment.startTime != null &&
                                  assignment.endTime != null &&
                                  now.isAfter(assignment.startTime!) &&
                                  now.isBefore(assignment.endTime!);

                              final statusText = assignment.hasSubmitted
                                  ? "Đã nộp bài"
                                  : (assignment.startTime != null && now.isBefore(assignment.startTime!))
                                      ? "Chưa đến giờ làm bài"
                                      : (assignment.endTime != null && now.isAfter(assignment.endTime!))
                                          ? "Đã hết thời gian làm bài"
                                          : "Có thể làm bài";

                              return FadeInUp(
                                duration: Duration(milliseconds: 600 + (assignmentIndex * 100)),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                  elevation: 4.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          isDarkMode ? Colors.grey[700]! : Colors.white,
                                          isDarkMode ? Colors.grey[800]! : Colors.grey[50]!,
                                        ],
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      title: Text(
                                        assignment.title,
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
                                            "Loại: ${assignment.quizType == 'trac_nghiem' ? 'Trắc nghiệm' : 'Tự luận'}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            "Tổng điểm: ${assignment.totalPoints}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            "Thời gian: ${assignment.time} phút",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            "Bắt đầu: ${assignment.startTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(assignment.startTime!.toLocal()) : 'Chưa xác định'}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            "Kết thúc: ${assignment.endTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(assignment.endTime!.toLocal()) : 'Chưa xác định'}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            "Trạng thái: $statusText",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: assignment.hasSubmitted
                                                  ? Colors.green
                                                  : (assignment.startTime != null && now.isBefore(assignment.startTime!))
                                                      ? Colors.orange
                                                      : (assignment.endTime != null && now.isAfter(assignment.endTime!))
                                                          ? Colors.red
                                                          : Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: ScaleTransitionButton(
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
                                            : () {
                                                if (assignment.hasSubmitted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: const Text('Bạn đã nộp bài này rồi!'),
                                                      backgroundColor: Colors.orange,
                                                      behavior: SnackBarBehavior.floating,
                                                      margin: const EdgeInsets.all(16.0),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                          decoration: BoxDecoration(
                                            gradient: canDoExercise
                                                ? LinearGradient(
                                                    colors: [
                                                      Colors.blue[600]!,
                                                      Colors.blue[800]!,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                            color: canDoExercise ? null : Colors.grey[400],
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            "Làm bài",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: canDoExercise ? Colors.white : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback? onPressed;
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
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              _controller.reverse();
              widget.onPressed!();
            }
          : null,
      onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}