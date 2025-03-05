import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  String? qrData; // Lưu dữ liệu mã QR
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
        // Chỉ cập nhật qrData từ server nếu chưa có giá trị từ startAttendance
        if (qrData == null && response["qr_data"] != null) {
          qrData = response["qr_data"];
        }
      });
    } catch (e) {
      if (!mounted) return;
      // Không hiển thị lỗi, để logic trong build xử lý
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mở điểm danh thành công!")));
      await checkAttendanceStatus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<void> closeAttendance() async {
    try {
      final absentList = await ref.read(closeAttendanceProvider({
        "tkb_id": widget.tkbId,
        "student_ids": presentStudents.map((student) => student['student_id']).toList()
      }).future);
      if (!mounted) return;
      setState(() {
        isAttendanceOpen = false;
        absentStudents = absentList.map((id) => {'student_id': id}).toList();
        qrData = null;
      });
      ref.invalidate(attendanceListProvider(widget.tkbId));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã đóng điểm danh!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final attendanceListAsync = ref.watch(attendanceListProvider(widget.tkbId));

    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý điểm danh")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Thời gian điểm danh (phút)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: attendanceListAsync.when(
                    data: (data) => data["is_open"] ? null : startAttendance,
                    loading: () => null,
                    error: (_, __) => startAttendance,
                  ),
                  child: const Text("Mở điểm danh"),
                ),
              ],
            ),
          ),
          if (qrData != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text("Mã QR điểm danh:", style: TextStyle(fontWeight: FontWeight.bold)),
                  QrImageView(
                    data: qrData!,
                    version: QrVersions.auto,
                    size: 200.0,
                    foregroundColor: isDarkMode ? Colors.white : Colors.black,
                    backgroundColor: isDarkMode ? Colors.black : Colors.white,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: attendanceListAsync.when(
              data: (data) {
                presentStudents = data["present"] ?? [];
                absentStudents = data["absent"] ?? [];
                isAttendanceOpen = data["is_open"] ?? false;
                // Không ghi đè qrData từ server, giữ giá trị từ startAttendance
                return ListView(
                  children: [
                    if (presentStudents.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("✅ Sinh viên đã điểm danh:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ...presentStudents.map((student) => ListTile(
                                title: Text("${student['mssv']} - ${student['full_name']}"),
                              )),
                        ],
                      ),
                    if (absentStudents.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("❌ Sinh viên vắng:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ...absentStudents.map((student) => ListTile(
                                title: Text("${student['mssv'] ?? student['student_id']} - ${student['full_name'] ?? ''}"),
                              )),
                        ],
                      ),
                    if (presentStudents.isEmpty && absentStudents.isEmpty)
                      const Center(child: Text("Chưa có dữ liệu điểm danh")),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Center(
                child: Text(
                  "Chưa có phiên điểm danh nào được mở",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
          if (isAttendanceOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: closeAttendance,
                child: const Text("Đóng điểm danh"),
              ),
            ),
        ],
      ),
    );
  }
}