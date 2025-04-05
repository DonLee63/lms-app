import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/exercise_provider.dart';

class StudentAverageScoresScreen extends ConsumerWidget {
  final int hocphanId;

  const StudentAverageScoresScreen({
    super.key,
    required this.hocphanId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averageScoresAsync = ref.watch(studentAverageScoresProvider(hocphanId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Điểm trung bình sinh viên',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
      body: averageScoresAsync.when(
        data: (data) {
          if (!data['success']) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['message'],
                    style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final hocphanData = data['data'];
          final students = (hocphanData['students'] as List<dynamic>)
              .map((student) => student as Map<String, dynamic>)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Danh sách sinh viên:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final averageScore = student['average_score'] ?? 0;
                      final submissions = (student['submissions'] as List<dynamic>)
                          .map((submission) => submission as Map<String, dynamic>)
                          .toList();

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
                                    CircleAvatar(
                                      backgroundColor: Colors.blue[700],
                                      radius: 20,
                                      child: Text(
                                        student['student_name'].substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student['student_name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode ? Colors.white : Colors.blue[900],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Mã sinh viên: ${student['mssv']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.yellow[700], size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Điểm trung bình: $averageScore',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                                if (submissions.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Danh sách bài nộp:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...submissions.map((submission) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.assignment, size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              submission['assignment_title'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Điểm: ${submission['score']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
}