import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_course_report_screen.dart';
import '../../providers/course_provider.dart';

class TeacherReportScreen extends ConsumerWidget {
  final int teacherId;

  const TeacherReportScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(teacherReportProvider(teacherId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Thống kê và báo cáo',
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
            onPressed: () => ref.invalidate(teacherReportProvider(teacherId)),
            tooltip: 'Làm mới dữ liệu',
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
      body: reportAsync.when(
        data: (report) {
          final totalCourses = (report['total_courses'] as num).toInt();
          final totalStudents = (report['total_students'] as num).toInt();
          final passRate = (report['pass_rate'] as num).toDouble();
          final averageScore = (report['average_score'] as num).toDouble();
          final courses = report['courses'] as List<dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thống kê tổng quan
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Card(
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tổng quan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  'Số học phần',
                                  totalCourses.toString(),
                                  Icons.book,
                                  Colors.blue[700]!,
                                  isDarkMode,
                                ),
                                _buildStatCard(
                                  'Tổng sinh viên',
                                  totalStudents.toString(),
                                  Icons.people,
                                  Colors.green[700]!,
                                  isDarkMode,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  'Điểm trung bình',
                                  averageScore.toStringAsFixed(2),
                                  Icons.score,
                                  Colors.orange[700]!,
                                  isDarkMode,
                                ),
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: passRate,
                                          color: Colors.green[700],
                                          title: '${passRate.toStringAsFixed(1)}%',
                                          radius: 50,
                                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        PieChartSectionData(
                                          value: 100 - passRate,
                                          color: Colors.red[700],
                                          title: '${(100 - passRate).toStringAsFixed(1)}%',
                                          radius: 50,
                                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Tỷ lệ đạt (xanh) / Không đạt (đỏ)',
                                style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '(Điểm trung bình không bao gồm học phần điều kiện)',
                              style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Danh sách học phần
                  Text(
                    'Danh sách học phần',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (courses.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 48,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa phụ trách học phần nào',
                            style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 500 + (index * 100)),
                          child: Card(
                            elevation: 6.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      course['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.blue[900],
                                      ),
                                    ),
                                  ),
                                  if (course['is_condition_course'] == 1) ...[
                                    Chip(
                                      label: const Text(
                                        'Điều kiện',
                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                      backgroundColor: Colors.orange[700],
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCourseInfo('Tín chỉ:', course['so_tin_chi'].toString(), isDarkMode),
                                    _buildCourseInfo('Số sinh viên:', course['total_students'].toString(), isDarkMode),
                                    _buildCourseInfo('Tỷ lệ đạt:', '${course['pass_rate'].toStringAsFixed(1)}%', isDarkMode),
                                    _buildCourseInfo('Điểm trung bình:', course['average_score'].toStringAsFixed(2), isDarkMode),
                                    if (course['is_condition_course'] == 1) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '(Điểm trung bình không áp dụng)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blue[700],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeacherCourseReportScreen(
                                      teacherId: teacherId,
                                      phancongId: course['phancong_id'],
                                      hocphanId: course['hocphan_id'],
                                      courseTitle: course['title'],
                                      students: course['students'],
                                      isConditionCourse: course['is_condition_course'] == 1,
                                      passRate: (course['pass_rate'] as num).toDouble(),
                                      averageScore: (course['average_score'] as num).toDouble(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                ],
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      width: 140,
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

  Widget _buildCourseInfo(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        '$label $value',
        style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
      ),
    );
  }
}