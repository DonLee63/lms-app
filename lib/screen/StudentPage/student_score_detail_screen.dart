import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/course_provider.dart';

class StudentScoreDetailScreen extends ConsumerStatefulWidget {
  final int studentId;
  final int hocphanId;
  final String courseTitle;

  const StudentScoreDetailScreen({
    super.key,
    required this.studentId,
    required this.hocphanId,
    required this.courseTitle,
  });

  @override
  ConsumerState<StudentScoreDetailScreen> createState() => _StudentScoreDetailScreenState();
}

class _StudentScoreDetailScreenState extends ConsumerState<StudentScoreDetailScreen> {
  late Future<Map<String, dynamic>> _scoresFuture;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() {
    _scoresFuture = ref.read(studentScoresProvider({
      'studentId': widget.studentId,
      'hocphanId': widget.hocphanId,
    }).future);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
              setState(() {
                _loadScores();
              });
              ref.invalidate(studentScoresProvider({
                'studentId': widget.studentId,
                'hocphanId': widget.hocphanId,
              }));
            },
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _scoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),
            );
          }

          final score = snapshot.data ?? <String, dynamic>{};

          if (score.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 48,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có điểm cho học phần này',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    // Course Info Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 6.0,
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blue[100],
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.blue[800],
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Học phần: ${score['hocphan_title']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.blue[900],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_score,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Số tín chỉ: ${score['so_tin_chi']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Scores Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 6.0,
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chi tiết điểm',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._buildScoreRows(score, isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildScoreRows(Map<String, dynamic> score, bool isDarkMode) {
    final scoreLabels = {
      'Điểm bộ phận': score['DiemBP']?.toString() ?? 'Chưa có',
      'Điểm thi 1': score['Thi1']?.toString() ?? 'Chưa có',
      'Điểm tổng 1': score['Diem1']?.toString() ?? 'Chưa có',
      'Điểm thi 2': score['Thi2']?.toString() ?? 'Chưa có',
      'Điểm tổng 2': score['Diem2']?.toString() ?? 'Chưa có',
      'Điểm cao nhất': score['DiemMax']?.toString() ?? 'Chưa có',
      'Điểm chữ': score['DiemChu'] ?? 'Chưa có',
      'Điểm hệ số 4': score['DiemHeSo4']?.toString() ?? 'Chưa có',
    };

    return scoreLabels.entries.map((entry) {
      final isScoreAvailable = entry.value != 'Chưa có';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isScoreAvailable ? Icons.check_circle : Icons.pending,
                  color: isScoreAvailable
                      ? (isDarkMode ? Colors.blue[300] : Colors.blue[800])
                      : (isDarkMode ? Colors.grey[600] : Colors.grey[500]),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isScoreAvailable
                    ? (isDarkMode ? Colors.blue[900] : Colors.blue[100])
                    : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isScoreAvailable
                      ? (isDarkMode ? Colors.white : Colors.blue[900])
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}