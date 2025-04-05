import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/course_provider.dart';

class StudentProgressScreen extends ConsumerWidget {
  final int studentId;

  const StudentProgressScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(studentProgressProvider(studentId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Tiến độ học tập',
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
            onPressed: () => ref.invalidate(studentProgressProvider(studentId)),
            tooltip: 'Làm mới',
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
      body: progressAsync.when(
        data: (progress) {
          final progressData = progress['courses'] as List<dynamic>;
          final totalCreditsCompleted = (progress['total_credits_completed'] as num).toDouble();
          final totalCredits = (progress['total_credits'] as num).toDouble();
          final gpa = (progress['gpa'] as num).toDouble();
          final progressPercentage = (progress['progress_percentage'] as num).toDouble();
          final requiredCredits = (progress['required_credits'] as num).toDouble();

          final completedCourses = progressData.where((course) => course['is_completed'] == true).toList();
          final ongoingCourses = progressData.where((course) => course['is_completed'] != true).toList();

          final normalCompletedCredits = completedCourses
              .where((course) => course['is_condition_course'] == 0)
              .fold<double>(0.0, (sum, course) => sum + (course['so_tin_chi'] as num).toDouble());
          final conditionCompletedCredits = completedCourses
              .where((course) => course['is_condition_course'] == 1)
              .fold<double>(0.0, (sum, course) => sum + (course['so_tin_chi'] as num).toDouble());

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tổng quan
                    Card(
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue[100],
                                  child: Icon(Icons.school, color: Colors.blue[800], size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Tổng quan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  'Tín chỉ hoàn thành',
                                  totalCreditsCompleted.toStringAsFixed(1),
                                  Icons.check_circle,
                                  Colors.green[700]!,
                                  isDarkMode,
                                ),
                                _buildStatCard(
                                  'GPA',
                                  gpa.toStringAsFixed(2),
                                  Icons.score,
                                  Colors.blue[700]!,
                                  isDarkMode,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tiến độ: ${progressPercentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : Colors.blue[900],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: progressPercentage / 100,
                                        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          progressPercentage >= 75
                                              ? Colors.green[700]!
                                              : progressPercentage >= 50
                                                  ? Colors.orange[700]!
                                                  : Colors.red[700]!,
                                        ),
                                        minHeight: 10,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yêu cầu: $totalCreditsCompleted / $requiredCredits tín chỉ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: normalCompletedCredits,
                                          color: Colors.blue[700],
                                          title: normalCompletedCredits > 0 ? '${normalCompletedCredits.toStringAsFixed(1)}' : '',
                                          radius: 40,
                                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        PieChartSectionData(
                                          value: conditionCompletedCredits,
                                          color: Colors.orange[700],
                                          title: conditionCompletedCredits > 0 ? '${conditionCompletedCredits.toStringAsFixed(1)}' : '',
                                          radius: 40,
                                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegend('Thường', Colors.blue[700]!, isDarkMode),
                                const SizedBox(width: 16),
                                _buildLegend('Điều kiện', Colors.orange[700]!, isDarkMode),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Học phần đã hoàn thành
                    Text(
                      'Học phần đã hoàn thành (${completedCourses.length})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (completedCourses.isEmpty)
                      _buildEmptyState('Chưa hoàn thành học phần nào', isDarkMode),
                    ...completedCourses.map(
                      (course) => _buildCourseCard(course, true, isDarkMode),
                    ),
                    const SizedBox(height: 24),
                    // Học phần đang học
                    Text(
                      'Học phần đang học (${ongoingCourses.length})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (ongoingCourses.isEmpty)
                      _buildEmptyState('Không có học phần nào đang học', isDarkMode),
                    ...ongoingCourses.map(
                      (course) => _buildCourseCard(course, false, isDarkMode),
                    ),
                  ],
                ),
              ),
            ),
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
              Icon(Icons.error_outline, size: 48, color: isDarkMode ? Colors.red[300] : Colors.red[600]),
              const SizedBox(height: 16),
              Text('Lỗi: $error', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(dynamic course, bool isCompleted, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4.0,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isCompleted ? Colors.green[100] : Colors.orange[100],
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.pending,
                color: isCompleted ? Colors.green[700] : Colors.orange[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.blue[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (course['is_condition_course'] == 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Chip(
                            label: const Text('Điều kiện', style: TextStyle(fontSize: 12, color: Colors.white)),
                            backgroundColor: Colors.orange[700],
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tín chỉ: ${course['so_tin_chi']}',
                    style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                  ),
                  if (isCompleted) ...[
                    Text(
                      'Điểm hệ số 4: ${course['diem_he_so_4']?.toStringAsFixed(1) ?? 'Chưa có'}',
                      style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    Text(
                      'Điểm chữ: ${course['diem_chu'] ?? 'Chưa có'}',
                      style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}