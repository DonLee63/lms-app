import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/course_provider.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  final int studentId;

  const StudentAttendanceScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> {
  bool _isFirstLoad = true; // Biến để kiểm soát lần đầu vào trang

  @override
  void initState() {
    super.initState();
    // Không gọi ref ở đây nữa
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ làm mới dữ liệu khi vào trang lần đầu
    if (_isFirstLoad) {
      final timetable = ref.read(timetableProvider(widget.studentId)).valueOrNull ?? [];
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      for (var schedule in timetable) {
        if (today == schedule['ngay']) {
          ref.invalidate(attendanceListProvider(schedule['timetable_id']));
        }
      }
      _isFirstLoad = false; // Đánh dấu đã tải lần đầu
    }
  }

  Future<void> _refreshData(WidgetRef ref) async {
    // Làm mới dữ liệu cho tất cả buổi học hôm nay
    final timetable = ref.read(timetableProvider(widget.studentId)).valueOrNull ?? [];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (var schedule in timetable) {
      if (schedule['ngay'] == today) {
        ref.invalidate(attendanceListProvider(schedule['timetable_id']));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(timetableProvider(widget.studentId));
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text("Điểm danh sinh viên")),
      body: timetableAsync.when(
        data: (timetable) {
          final todayClasses = timetable.where((schedule) => schedule['ngay'] == today).toList();

          if (todayClasses.isEmpty) {
            return const Center(child: Text("Hôm nay không có buổi học nào."));
          }

          return RefreshIndicator(
            onRefresh: () => _refreshData(ref),
            child: ListView.builder(
              itemCount: todayClasses.length,
              itemBuilder: (context, index) {
                final schedule = todayClasses[index];
                final tkbId = schedule['timetable_id'];
                final subjectName = schedule['title'];
                final attendanceStatusAsync = ref.watch(attendanceListProvider(tkbId));

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Ngày: ${schedule['ngay']} - Buổi: ${schedule['buoi']}"),
                    trailing: attendanceStatusAsync.when(
                      data: (attendanceData) {
                        final presentStudents = attendanceData["present"] as List<dynamic>? ?? [];
                        final absentStudents = attendanceData["absent"] as List<dynamic>? ?? [];
                        final isAttendanceOpen = attendanceData["is_open"] as bool? ?? false;

                        final hasMarked = presentStudents.any((student) => student['student_id'] == widget.studentId);

                        return hasMarked
                            ? const Text("✅ Đã điểm danh", style: TextStyle(color: Colors.green))
                            : isAttendanceOpen
                                ? ElevatedButton(
                                    onPressed: () => _markAttendance(context, ref, tkbId, widget.studentId),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                    child: const Text("Điểm danh"),
                                  )
                                : const Text("🚫 Điểm danh đã đóng", style: TextStyle(color: Colors.red));
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Lỗi: $error")),
      ),
    );
  }

  void _markAttendance(BuildContext context, WidgetRef ref, int tkbId, int studentId) async {
    try {
      await ref.read(markAttendanceProvider({"tkb_id": tkbId, "student_id": studentId}).future);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Điểm danh thành công!"), backgroundColor: Colors.green),
      );
      ref.invalidate(attendanceListProvider(tkbId));
    } catch (e) {
      String errorMessage = "Lỗi điểm danh: $e";
      if (e.toString().contains("403")) {
        errorMessage = "Điểm danh đã đóng. Vui lòng liên hệ giảng viên!";
      } else if (e.toString().contains("network")) {
        errorMessage = "Lỗi kết nối mạng. Vui lòng kiểm tra lại!";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }
}
