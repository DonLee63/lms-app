import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final TextEditingController durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tải danh sách điểm danh khi vào trang
    checkAttendanceStatus();
  }

  // Kiểm tra trạng thái điểm danh hiện tại
  Future<void> checkAttendanceStatus() async {
    try {
      final response = await ref.read(attendanceListProvider(widget.tkbId).future);
      setState(() {
        presentStudents = response["present"] ?? [];
        absentStudents = response["absent"] ?? [];
        // API hiện tại không trả về is_open, bạn cần thêm logic nếu muốn kiểm tra trạng thái
        isAttendanceOpen = presentStudents.isNotEmpty || absentStudents.isNotEmpty;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // Mở điểm danh
  Future<void> startAttendance() async {
    final duration = int.tryParse(durationController.text) ?? 5; // Mặc định 5 phút nếu không nhập
    try {
      await ref.read(startAttendanceProvider({"tkb_id": widget.tkbId, "duration": duration}).future);
      setState(() {
        isAttendanceOpen = true;
        presentStudents = [];
        absentStudents = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mở điểm danh thành công!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // Đóng điểm danh
  Future<void> closeAttendance() async {
    try {
      final absentList = await ref.read(closeAttendanceProvider({"tkb_id": widget.tkbId, "student_ids": presentStudents.map((student) => student['student_id']).toList()}).future);
      setState(() {
        isAttendanceOpen = false;
        absentStudents = absentList;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã đóng điểm danh!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceListAsync = ref.watch(attendanceListProvider(widget.tkbId));
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý điểm danh")),
      body: Column(
        children: [
          // Nhập thời gian điểm danh
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
                    data: (data) => isAttendanceOpen ? null : startAttendance,
                    loading: () => null,
                    error: (_, __) => startAttendance,
                  ),
                  child: const Text("Mở điểm danh"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Danh sách sinh viên điểm danh
          Expanded(
            child: attendanceListAsync.when(
              data: (data) {
                presentStudents = data["present"] ?? [];
                absentStudents = data["absent"] ?? [];
                // Cập nhật trạng thái điểm danh dựa trên dữ liệu (nếu cần)
                isAttendanceOpen = presentStudents.isNotEmpty || absentStudents.isNotEmpty;

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
                                title: Text("${student['mssv']} - ${student['full_name']}"),
                              )),
                        ],
                      ),
                    if (presentStudents.isEmpty && absentStudents.isEmpty)
                      const Center(child: Text("Chưa có dữ liệu điểm danh")),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text("Lỗi khi tải danh sách: $error")),
            ),
          ),

          // Nút đóng điểm danh
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