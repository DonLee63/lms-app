import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // Gọi API một lần khi vào màn hình
    _loadScores();
  }

  void _loadScores() {
    // Sử dụng ref.read để gọi API một lần
    _scoresFuture = ref.read(studentScoresProvider({
      'studentId': widget.studentId,
      'hocphanId': widget.hocphanId,
    }).future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Điểm chi tiết - ${widget.courseTitle}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Làm mới dữ liệu khi nhấn nút refresh
              setState(() {
                _loadScores();
              });
              // Invalidate provider để đảm bảo dữ liệu được làm mới
              ref.invalidate(studentScoresProvider({
                'studentId': widget.studentId,
                'hocphanId': widget.hocphanId,
              }));
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _scoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Không cần kiểm tra snapshot.hasError, vì lỗi đã được xử lý trong repository
          final score = snapshot.data ?? <String, dynamic>{};

          // Kiểm tra nếu score rỗng (không có điểm)
          if (score.isEmpty) {
            return const Center(child: Text('Chưa có điểm cho học phần này.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Học phần: ${score['hocphan_title']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Số tín chỉ: ${score['so_tin_chi']}'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildScoreRow('Điểm bộ phận', score['DiemBP']?.toString() ?? 'Chưa có'),
                    _buildScoreRow('Điểm thi 1', score['Thi1']?.toString() ?? 'Chưa có'),
                    _buildScoreRow('Điểm tổng 1', score['Diem1']?.toString() ?? 'Chưa có'),
                    _buildScoreRow('Điểm thi 2', score['Thi2']?.toString() ?? 'Chưa có'),
                    _buildScoreRow('Điểm tổng 2', score['Diem2']?.toString() ?? 'Chưa có'),
                    _buildScoreRow('Điểm cao nhất', score['DiemMax']?.toString() ?? 'Chưa có'),
                    _buildScoreRow('Điểm chữ', score['DiemChu'] ?? 'Chưa có'),
                    _buildScoreRow('Điểm hệ số 4', score['DiemHeSo4']?.toString() ?? 'Chưa có'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}