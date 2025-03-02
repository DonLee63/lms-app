import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/attendance_reponsitory.dart';

// Provider cho repository
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

// Provider để giảng viên mở điểm danh
final startAttendanceProvider = FutureProvider.family<String, Map<String, int>>((ref, params) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return await repository.startAttendance(params['tkb_id']!, params['duration']!); // Trả về qr_data
});

// Provider để sinh viên điểm danh
final markAttendanceProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  await repository.markAttendance(
    params['tkb_id']!,
    params['student_id']!,
    params['qr_token']!, // Thêm qr_token
  );
});

// Provider để giảng viên đóng điểm danh
final closeAttendanceProvider = FutureProvider.family<List<int>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return await repository.closeAttendance(params['tkb_id']!, List<int>.from(params['student_ids']!));
});

// Provider để lấy danh sách sinh viên đã điểm danh
final attendanceListProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, tkbId) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return await repository.getAttendanceList(tkbId);
});


