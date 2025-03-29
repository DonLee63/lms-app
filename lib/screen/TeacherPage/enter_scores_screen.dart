import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // Lấy danh sách sinh viên
    studentsFuture = ref.read(courseRepositoryProvider).getStudentsByTeacher(
          widget.teacherId,
          widget.phancongId,
        );
  }

  Future<Map<String, dynamic>> _loadStudentScores(int studentId) async {
    // Lấy điểm của sinh viên từ API
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
    // Giải phóng các controller khi widget bị hủy
    controllers.forEach((_, controllerMap) {
      controllerMap.forEach((_, controller) => controller.dispose());
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập điểm sinh viên'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error.toString()}'));
            }

            final students = snapshot.data ?? [];
            if (students.isEmpty) {
              return const Center(child: Text('Không có sinh viên nào.'));
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final student = students[index];
                final studentId = student['student_id'];

                // Lấy điểm của sinh viên
                return FutureBuilder<Map<String, dynamic>>(
                  future: _loadStudentScores(studentId),
                  builder: (context, scoreSnapshot) {
                    if (scoreSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Không cần kiểm tra scoreSnapshot.hasError, vì lỗi đã được xử lý trong repository
                    final score = scoreSnapshot.data ?? <String, dynamic>{};

                    // Khởi tạo controller với điểm cũ (nếu có)
                    if (!controllers.containsKey(studentId)) {
                      controllers[studentId] = {
                        'DiemBP': TextEditingController(
                          text: score['DiemBP']?.toString() ?? '',
                        ),
                        'Thi1': TextEditingController(
                          text: score['Thi1']?.toString() ?? '',
                        ),
                        'Thi2': TextEditingController(
                          text: score['Thi2']?.toString() ?? '',
                        ),
                      };
                    }

                    final diemBPController = controllers[studentId]!['DiemBP']!;
                    final thi1Controller = controllers[studentId]!['Thi1']!;
                    final thi2Controller = controllers[studentId]!['Thi2']!;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          student['student_name'].substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(student['student_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lớp: ${student['class_name'] ?? 'Không xác định'} - Môn: ${student['subject'] ?? 'Không xác định'}',
                          ),
                          const SizedBox(height: 8),
                          // Các ô nhập điểm
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: diemBPController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Điểm bộ phận',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: thi1Controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Điểm thi 1',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: thi2Controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Điểm thi 2',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Lấy giá trị từ các ô nhập
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

                                // Gọi API để cập nhật điểm
                                final updateResult = ref.read(updateScoreProvider({
                                  'studentId': studentId,
                                  'hocphanId': widget.hocphanId,
                                  'diemBP': diemBP,
                                  'thi1': thi1,
                                  'thi2': thi2,
                                }).future);

                                updateResult.then((result) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'])),
                                  );
                                  // Làm mới danh sách sinh viên sau khi cập nhật điểm
                                  _refresh();
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lỗi: $error')),
                                  );
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Lưu'),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.email, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Email: ${student['student_email'] ?? 'Không có email'}')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}