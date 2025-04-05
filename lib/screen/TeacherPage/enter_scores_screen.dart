import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/course_provider.dart';

class EnterScoresScreen extends ConsumerStatefulWidget {
  final int hocphanId;
  final int teacherId;
  final int phancongId;

  const EnterScoresScreen({
    super.key,
    required this.hocphanId,
    required this.teacherId,
    required this.phancongId,
  });

  @override
  ConsumerState<EnterScoresScreen> createState() => _EnterScoresScreenState();
}

class _EnterScoresScreenState extends ConsumerState<EnterScoresScreen> {
  Map<int, Map<String, TextEditingController>> controllers = {};
  late Future<List<Map<String, dynamic>>> studentsFuture;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    studentsFuture = ref.read(courseRepositoryProvider).getStudentsByTeacher(
          widget.teacherId,
          widget.phancongId,
        );
  }

  Future<Map<String, dynamic>> _loadStudentScores(int studentId) async {
    return ref.read(studentScoresProvider({
      'studentId': studentId,
      'hocphanId': widget.hocphanId,
    }).future);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadStudents();
    });
    await studentsFuture;
  }

  @override
  void dispose() {
    controllers.forEach((_, controllerMap) {
      controllerMap.forEach((_, controller) => controller.dispose());
    });
    super.dispose();
  }

  Future<void> _saveAllScores() async {
    for (final studentId in controllers.keys) {
      final diemBP = double.tryParse(controllers[studentId]!['DiemBP']!.text);
      final thi1 = double.tryParse(controllers[studentId]!['Thi1']!.text);
      final thi2 = double.tryParse(controllers[studentId]!['Thi2']!.text);

      if (diemBP != null && (diemBP < 0 || diemBP > 10)) continue;
      if (thi1 != null && (thi1 < 0 || thi1 > 10)) continue;
      if (thi2 != null && (thi2 < 0 || thi2 > 10)) continue;

      try {
        await ref.read(updateScoreProvider({
          'studentId': studentId,
          'hocphanId': widget.hocphanId,
          'diemBP': diemBP,
          'thi1': thi1,
          'thi2': thi2,
        }).future);
      } catch (e) {
        // Bỏ qua lỗi cho từng sinh viên để tiếp tục lưu các sinh viên khác
      }
    }
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu tất cả điểm hợp lệ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Nhập điểm sinh viên',
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
            onPressed: _refresh,
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 5, // Hiển thị 5 skeleton placeholder
                itemBuilder: (context, index) => FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: _buildSkeletonItem(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: isDarkMode ? Colors.red[300] : Colors.red[600]),
                    const SizedBox(height: 16),
                    Text('Lỗi: ${snapshot.error}', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              );
            }

            final students = snapshot.data ?? [];
            if (students.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 48, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(height: 16),
                    Text('Không có sinh viên nào', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final studentId = student['student_id'];

                return FadeInUp(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  child: _buildStudentTile(student, studentId, isDarkMode),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAllScores,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.save),
        tooltip: 'Lưu tất cả',
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 16, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 12, color: Colors.grey[300]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student, int studentId, bool isDarkMode) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[700],
          child: Text(
            student['student_name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          student['student_name'],
          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.blue[900]),
        ),
        subtitle: Text(
          'Lớp: ${student['class_name'] ?? 'Không xác định'}',
          style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
        ),
        trailing: IconButton(
          icon: Icon(Icons.email, color: Colors.blue[700]),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email: ${student['student_email'] ?? 'Không có email'}')),
            );
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _loadStudentScores(studentId),
              builder: (context, scoreSnapshot) {
                if (scoreSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final score = scoreSnapshot.data ?? <String, dynamic>{};

                if (!controllers.containsKey(studentId)) {
                  controllers[studentId] = {
                    'DiemBP': TextEditingController(text: score['DiemBP']?.toString() ?? ''),
                    'Thi1': TextEditingController(text: score['Thi1']?.toString() ?? ''),
                    'Thi2': TextEditingController(text: score['Thi2']?.toString() ?? ''),
                  };
                }

                final diemBPController = controllers[studentId]!['DiemBP']!;
                final thi1Controller = controllers[studentId]!['Thi1']!;
                final thi2Controller = controllers[studentId]!['Thi2']!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildScoreField('Điểm bộ phận', diemBPController, isDarkMode),
                        const SizedBox(width: 8),
                        _buildScoreField('Điểm thi 1', thi1Controller, isDarkMode),
                        const SizedBox(width: 8),
                        _buildScoreField('Điểm thi 2', thi2Controller, isDarkMode),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final diemBP = double.tryParse(diemBPController.text);
                          final thi1 = double.tryParse(thi1Controller.text);
                          final thi2 = double.tryParse(thi2Controller.text);

                          if (diemBP == null || diemBP < 0 || diemBP > 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Điểm bộ phận phải từ 0 đến 10')),
                            );
                            return;
                          }
                          if (thi1 != null && (thi1 < 0 || thi1 > 10)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Điểm thi 1 phải từ 0 đến 10')),
                            );
                            return;
                          }
                          if (thi2 != null && (thi2 < 0 || thi2 > 10)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Điểm thi 2 phải từ 0 đến 10')),
                            );
                            return;
                          }

                          try {
                            final result = await ref.read(updateScoreProvider({
                              'studentId': studentId,
                              'hocphanId': widget.hocphanId,
                              'diemBP': diemBP,
                              'thi1': thi1,
                              'thi2': thi2,
                            }).future);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message']), backgroundColor: Colors.green[700]),
                            );
                            _refresh();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red[700]),
                            );
                          }
                        },
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Lưu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreField(String label, TextEditingController controller, bool isDarkMode) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        ),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}