import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/attendance_provider.dart';

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  final int tkbId;

  const TeacherAttendanceScreen({super.key, required this.tkbId});

  @override
  ConsumerState<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends ConsumerState<TeacherAttendanceScreen> {
  bool isAttendanceOpen = false;
  List<dynamic> presentStudents = [];
  List<dynamic> absentStudents = [];
  String? qrData;
  final TextEditingController durationController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    ref.invalidate(attendanceListProvider(widget.tkbId));
    checkAttendanceStatus();
  }

  Future<void> checkAttendanceStatus() async {
    try {
      final response = await ref.read(attendanceListProvider(widget.tkbId).future);
      if (!mounted) return;
      setState(() {
        presentStudents = response["present"] ?? [];
        absentStudents = response["absent"] ?? [];
        isAttendanceOpen = response["is_open"] ?? false;
        if (qrData == null && response["qr_data"] != null) {
          qrData = response["qr_data"];
        }
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  Future<void> startAttendance() async {
    final duration = int.tryParse(durationController.text) ?? 5;
    try {
      qrData = await ref.read(startAttendanceProvider({
        "tkb_id": widget.tkbId,
        "duration": duration,
      }).future);
      if (!mounted) return;
      ref.invalidate(attendanceListProvider(widget.tkbId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Mở điểm danh thành công!"), backgroundColor: Colors.green[700]),
      );
      await checkAttendanceStatus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red[700]),
      );
    }
  }

  Future<void> closeAttendance() async {
    try {
      final absentList = await ref.read(closeAttendanceProvider({
        "tkb_id": widget.tkbId,
        "student_ids": presentStudents.map((student) => student['student_id']).toList(),
      }).future);
      if (!mounted) return;
      setState(() {
        isAttendanceOpen = false;
        absentStudents = absentList.map((id) => {'student_id': id}).toList();
        qrData = null;
      });
      ref.invalidate(attendanceListProvider(widget.tkbId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Đã đóng điểm danh!"), backgroundColor: Colors.green[700]),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red[700]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final attendanceListAsync = ref.watch(attendanceListProvider(widget.tkbId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Quản lý điểm danh',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Thời gian điểm danh (phút)',
                        labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: attendanceListAsync.when(
                      data: (data) => data["is_open"] ? null : startAttendance,
                      loading: () => null,
                      error: (_, __) => startAttendance,
                    ),
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('Mở điểm danh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (qrData != null)
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Text(
                      'Mã QR điểm danh:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    QrImageView(
                      data: qrData!,
                      version: QrVersions.auto,
                      size: 200.0,
                      foregroundColor: isDarkMode ? Colors.white : Colors.black,
                      backgroundColor: isDarkMode ? Colors.black : Colors.white,
                      padding: const EdgeInsets.all(16),
                      embeddedImage: const AssetImage('assets/qr_logo.png'), // Optional: thêm logo giữa QR
                      embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: attendanceListAsync.when(
              data: (data) {
                presentStudents = data["present"] ?? [];
                absentStudents = data["absent"] ?? [];
                isAttendanceOpen = data["is_open"] ?? false;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (presentStudents.isNotEmpty)
                        _buildStudentSection(
                          title: '✅ Sinh viên đã điểm danh (${presentStudents.length})',
                          students: presentStudents,
                          color: Colors.green[700]!,
                          isDarkMode: isDarkMode,
                        ),
                      if (absentStudents.isNotEmpty)
                        _buildStudentSection(
                          title: '❌ Sinh viên vắng (${absentStudents.length})',
                          students: absentStudents,
                          color: Colors.red[700]!,
                          isDarkMode: isDarkMode,
                        ),
                      if (presentStudents.isEmpty && absentStudents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có dữ liệu điểm danh',
                                  style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue))),
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
                      'Chưa có phiên điểm danh nào được mở',
                      style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isAttendanceOpen)
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: closeAttendance,
                  icon: const Icon(Icons.lock, size: 18),
                  label: const Text('Đóng điểm danh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(double.infinity, 50), // Full-width button
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentSection({
    required String title,
    required List<dynamic> students,
    required Color color,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ...students.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            return FadeInUp(
              duration: Duration(milliseconds: 500 + (index * 100)),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(
                      color == Colors.green[700] ? Icons.check_circle : Icons.cancel,
                      color: color,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    "${student['mssv'] ?? student['student_id']} - ${student['full_name'] ?? ''}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  trailing: Icon(
                    Icons.person,
                    color: color,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}