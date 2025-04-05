import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class TeacherCourseReportScreen extends StatelessWidget {
  final int teacherId;
  final int phancongId;
  final int hocphanId;
  final String courseTitle;
  final List<dynamic> students;
  final bool isConditionCourse;
  final double passRate;
  final double averageScore;

  const TeacherCourseReportScreen({
    super.key,
    required this.teacherId,
    required this.phancongId,
    required this.hocphanId,
    required this.courseTitle,
    required this.students,
    required this.isConditionCourse,
    required this.passRate,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Báo cáo - $courseTitle',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isConditionCourse) ...[
              const SizedBox(width: 8),
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thống kê học phần
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
                          'Thống kê học phần',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow('Số sinh viên:', students.length.toString(), isDarkMode),
                        const SizedBox(height: 12),
                        _buildStatRow('Tỷ lệ đạt:', '${passRate.toStringAsFixed(1)}%', isDarkMode),
                        const SizedBox(height: 12),
                        _buildStatRow('Điểm trung bình:', averageScore.toStringAsFixed(2), isDarkMode),
                        if (isConditionCourse) ...[
                          const SizedBox(height: 8),
                          Text(
                            '(Điểm trung bình không áp dụng cho học phần điều kiện)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Danh sách sinh viên
              Text(
                'Danh sách sinh viên',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue[900],
                ),
              ),
              const SizedBox(height: 12),
              if (students.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có sinh viên nào',
                        style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      child: Card(
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      student['student_name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.blue[900],
                                      ),
                                    ),
                                  ),
                                  if (student['is_condition_course'] == 1) ...[
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
                              const SizedBox(height: 8),
                              _buildStudentInfo('Lớp:', student['class_name'], isDarkMode),
                              _buildStudentInfo('Điểm bộ phận:', student['diem_bp']?.toString() ?? 'Chưa có', isDarkMode),
                              _buildStudentInfo('Điểm thi 1:', student['thi_1']?.toString() ?? 'Chưa có', isDarkMode),
                              _buildStudentInfo('Điểm thi 2:', student['thi_2']?.toString() ?? 'Chưa có', isDarkMode),
                              _buildStudentInfo('Điểm cao nhất:', student['diem_max']?.toString() ?? 'Chưa có', isDarkMode),
                              _buildStudentInfo('Điểm chữ:', student['diem_chu'] ?? 'Chưa có', isDarkMode),
                              _buildStudentInfo('Điểm hệ số 4:', student['diem_he_so_4']?.toStringAsFixed(1) ?? 'Chưa có', isDarkMode),
                              _buildStudentInfo(
                                'Trạng thái:',
                                student['is_passed'] == true ? 'Đạt' : 'Không đạt',
                                isDarkMode,
                                valueColor: student['is_passed'] == true ? Colors.green[700] : Colors.red[700],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.blue[900],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfo(String label, String value, bool isDarkMode, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? (isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}