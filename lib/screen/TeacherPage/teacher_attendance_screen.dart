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
  bool _isFirstLoad = true; // Biến để kiểm soát lần đầu vào trang

  @override
  void initState() {
    super.initState();
    // Không gọi ref.invalidate ở đây nữa
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ làm mới dữ liệu khi vào trang lần đầu
    if (_isFirstLoad) {
      ref.invalidate(attendanceListProvider(widget.tkbId));
      checkAttendanceStatus();
      _isFirstLoad = false; // Đánh dấu đã tải lần đầu
    }
  }

  Future<void> checkAttendanceStatus() async {
    try {
      final response = await ref.read(attendanceListProvider(widget.tkbId).future);
      setState(() {
        presentStudents = response["present"] ?? [];
        absentStudents = response["absent"] ?? [];
        isAttendanceOpen = response["is_open"] ?? false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<void> startAttendance() async {
    final duration = int.tryParse(durationController.text) ?? 5;
    try {
      await ref.read(startAttendanceProvider({"tkb_id": widget.tkbId, "duration": duration}).future);
      ref.invalidate(attendanceListProvider(widget.tkbId)); // Làm mới dữ liệu
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mở điểm danh thành công!")));
      await checkAttendanceStatus(); // Cập nhật trạng thái ngay sau khi mở
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<void> closeAttendance() async {
    try {
      final absentList = await ref.read(closeAttendanceProvider({
        "tkb_id": widget.tkbId,
        "student_ids": presentStudents.map((student) => student['student_id']).toList()
      }).future);
      setState(() {
        isAttendanceOpen = false;
        absentStudents = absentList.map((id) => {'student_id': id}).toList(); // Tạm thời chỉ có ID
      });
      ref.invalidate(attendanceListProvider(widget.tkbId)); // Làm mới dữ liệu
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã đóng điểm danh!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<void> _refreshData() async {
    ref.invalidate(attendanceListProvider(widget.tkbId));
    await checkAttendanceStatus(); // Cập nhật lại trạng thái sau khi làm mới
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: attendanceListAsync.when(
                data: (data) {
                  presentStudents = data["present"] ?? [];
                  absentStudents = data["absent"] ?? [];
                  isAttendanceOpen = data["is_open"] ?? false;

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
                error: (error, stack) => Center(child: Text("Lỗi khi tải danh sách: $error")),
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