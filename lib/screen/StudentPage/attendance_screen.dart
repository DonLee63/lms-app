import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/course_provider.dart';

class StudentAttendanceScreen extends ConsumerWidget {
  final int studentId;

  const StudentAttendanceScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableAsync = ref.watch(timetableProvider(studentId));
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Lấy ngày hiện tại

    return Scaffold(
      appBar: AppBar(title: const Text("Điểm danh sinh viên")),
      body: timetableAsync.when(
        data: (timetable) {
          // Lọc danh sách buổi học chỉ lấy của hôm nay
          final todayClasses = timetable.where((schedule) => schedule['ngay'] == today).toList();

          if (todayClasses.isEmpty) {
            return const Center(child: Text("Hôm nay không có buổi học nào."));
          }

          return ListView.builder(
            itemCount: todayClasses.length,
            itemBuilder: (context, index) {
              final schedule = todayClasses[index];
              final tkbId = schedule['timetable_id']; // ID của buổi học
              final subjectName = schedule['title']; // Tên môn học
              final time = schedule['time'] ?? 'Không rõ giờ'; // Giả định có trường time trong timetable
              final attendanceStatusAsync = ref.watch(attendanceListProvider(tkbId));

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Ngày: ${schedule['ngay']} | Giờ: $time"),
                  trailing: attendanceStatusAsync.when(
                    data: (attendanceData) {
                      final presentStudents = attendanceData["present"] as List<dynamic>? ?? [];
                      final absentStudents = attendanceData["absent"] as List<dynamic>? ?? [];

                      // Kiểm tra xem sinh viên đã điểm danh chưa (dựa trên student_id trong object)
                      final hasMarked = presentStudents.any((student) => student['student_id'] == studentId);

                      // Xác định trạng thái điểm danh dựa trên dữ liệu
                      final isAttendanceOpen = presentStudents.isNotEmpty || absentStudents.isNotEmpty;

                      return hasMarked
                          ? const Text("✅ Đã điểm danh", style: TextStyle(color: Colors.green))
                          : isAttendanceOpen
                              ? ElevatedButton(
                                  onPressed: () => _markAttendance(context, ref, tkbId, studentId),
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

      // Cập nhật lại danh sách điểm danh từ server
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