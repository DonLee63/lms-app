import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';
import '../repositories/course_reponsitory.dart';

// Provider cho CourseRepository
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository();
});

// FutureProvider cho danh sách học phần, phân loại theo học kỳ và loại
final groupedCoursesProvider = FutureProvider.family<Map<String, Map<String, List<Course>>>, int>((ref, studentId) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.getAvailableCourses(studentId);
});

final courseEnrollmentRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository();
});

// Provider cho việc đăng ký học phần
final courseEnrollmentProvider = FutureProvider.family<String, Map<String, int>>((ref, params) async {
  final repository = ref.watch(courseEnrollmentRepositoryProvider);
  final studentId = params['student_id']!;
  final phancongId = params['phancong_id']!;
  return repository.enrollCourse(studentId, phancongId);
});

// Provider cho danh sách học phần đã đăng ký (sử dụng model Enrollment)
final enrolledCoursesProvider = FutureProvider.family<List<Enrollment>, int>((ref, studentId) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.getEnrolledCourses(studentId);
});

// Provider cho việc xóa học phần
final deleteEnrollmentProvider = FutureProvider.family<String, int>((ref, enrollmentId) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.deleteEnrollment(enrollmentId);
});

// Provider để tìm kiếm học phần
final searchCoursesProvider = FutureProvider.autoDispose.family<List<Course>, SearchParams>((ref, params) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.searchCourses(params.studentId, keyword: params.keyword);
});

// Lớp chứa tham số tìm kiếm
class SearchParams {
  final int studentId;
  final String? keyword;

  SearchParams({required this.studentId, this.keyword});
}

// Provider lấy thời khóa biểu
final timetableProvider = FutureProvider.family<List<dynamic>, int>((ref, studentId) async {
  final repository = ref.read(courseRepositoryProvider);
  return await repository.fetchTimetable(studentId);
});

// Provider lấy danh sách sinh viên của một lớp (dành cho giảng viên)
final classStudentsProvider = FutureProvider.family<List<StudentModel>, int>((ref, teacherId) async {
  final repository = ref.read(courseRepositoryProvider);
  return await repository.getClassStudents(teacherId);
});


// Provider quản lý danh sách lịch thi của sinh viên
final examScheduleProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, studentId) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.getStudentExamSchedules(studentId);
});


final studentsByTeacherProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, int>>((ref, params) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.getStudentsByTeacher(params['teacher_id']!, params['phancong_id']!);
});


// Provider lấy danh sách lịch dạy
final teacherScheduleProvider = FutureProvider.family<List<dynamic>, int>((ref, teacherId) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.fetchTeacherSchedule(teacherId);
});

// Provider để cập nhật trạng thái của enrollment
final updateEnrollmentStatusProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(courseRepositoryProvider);
  final userId = params['userId'] as int;
  final enrollmentId = params['enrollmentId'] as int;
  final newStatus = params['newStatus'] as String;
  await repository.updateEnrollmentStatus(userId, enrollmentId, newStatus);
});

final updateScoreProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(courseRepositoryProvider);
  return repository.updateStudentScores(
    studentId: params['studentId'],
    hocphanId: params['hocphanId'],
    diemBP: params['diemBP'],
    thi1: params['thi1'],
    thi2: params['thi2'],
  );
});

// Provider để lấy điểm của sinh viên theo studentId và hocphanId
final studentScoresProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(courseRepositoryProvider);
  return repository.getStudentScores(
    params['studentId'] as int,
    params['hocphanId'] as int,
  );
});

// Provider để lấy dữ liệu tiến độ học tập
final studentProgressProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, studentId) async {
  final courseRepo = ref.read(courseRepositoryProvider);
  return courseRepo.getStudentProgress(studentId);
});

// Provider để lấy dữ liệu thống kê và báo cáo
final teacherReportProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, teacherId) async {
  final courseRepo = ref.read(courseRepositoryProvider);
  return courseRepo.getTeacherReport(teacherId);
});