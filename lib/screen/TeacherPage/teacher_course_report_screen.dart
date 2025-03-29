import 'package:flutter/material.dart';

class TeacherCourseReportScreen extends StatelessWidget {
  final int teacherId;
  final int phancongId;
  final int hocphanId;
  final String courseTitle;
  final List<dynamic> students;
  final bool isConditionCourse; // Thêm tham số
  final double passRate; // Thêm tham số
  final double averageScore; // Thêm tham số

  const TeacherCourseReportScreen({
    super.key,
    required this.teacherId,
    required this.phancongId,
    required this.hocphanId,
    required this.courseTitle,
    required this.students,
    required this.isConditionCourse, // Thêm vào constructor
    required this.passRate, // Thêm vào constructor
    required this.averageScore, // Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Báo cáo - $courseTitle'),
            if (isConditionCourse) ...[
              const SizedBox(width: 8),
              const Chip(
                label: Text(
                  'Điều kiện',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ],
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thống kê học phần
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thống kê học phần',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Số sinh viên:', style: TextStyle(fontSize: 16)),
                          Text(
                            students.length.toString(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tỷ lệ đạt:', style: TextStyle(fontSize: 16)),
                          Text(
                            '${passRate.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Điểm trung bình:', style: TextStyle(fontSize: 16)),
                          Text(
                            averageScore.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (isConditionCourse) ...[
                        const SizedBox(height: 4),
                        const Text(
                          '(Điểm trung bình không áp dụng cho học phần điều kiện)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Danh sách sinh viên
              const Text(
                'Danh sách sinh viên',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (students.isEmpty)
                const Text('Không có sinh viên nào.'),
              ...students.map((student) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              student['student_name'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (student['is_condition_course'] == 1) ...[
                            const Chip(
                              label: Text(
                                'Điều kiện',
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lớp: ${student['class_name']}'),
                          Text('Điểm bộ phận: ${student['diem_bp']?.toString() ?? 'Chưa có'}'),
                          Text('Điểm thi 1: ${student['thi_1']?.toString() ?? 'Chưa có'}'),
                          Text('Điểm thi 2: ${student['thi_2']?.toString() ?? 'Chưa có'}'),
                          Text('Điểm cao nhất: ${student['diem_max']?.toString() ?? 'Chưa có'}'),
                          Text('Điểm chữ: ${student['diem_chu'] ?? 'Chưa có'}'),
                          Text('Điểm hệ số 4: ${student['diem_he_so_4']?.toStringAsFixed(1) ?? 'Chưa có'}'),
                          Text('Trạng thái: ${student['is_passed'] == true ? 'Đạt' : 'Không đạt'}'),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}