import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/student_repository.dart';
import '../models/student.dart';
import 'dart:async';

final studentRepositoryProvider = StateNotifierProvider<StudentNotifier, AsyncValue<Student?>>(
  (ref) => StudentNotifier(StudentRepository()),
);

class StudentNotifier extends StateNotifier<AsyncValue<Student?>> {
  final StudentRepository repository;

  StudentNotifier(this.repository) : super(const AsyncValue.data(null));

  // Provider để tạo sinh viên
  Future<void> createStudent({
    required String mssv,
    required int donviId,
    required int nganhId,
    required int classId,
    required String khoa,
    required int userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final student = await repository.createStudent(
        mssv: mssv,
        donviId: donviId,
        nganhId: nganhId,
        classId: classId,
        khoa: khoa,
        userId: userId,
      );
      state = AsyncValue.data(student);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      rethrow;
    }
  }


 Future<Student?> showStudent(int userId) async {
  state = const AsyncValue.loading();
  try {
    final student = await repository.showStudent(userId);
    // Nếu `student` là null, đặt state là `AsyncValue.data(null)`
    if (student == null) {
      print('No student found for userId: $userId');
      state = AsyncValue.data(null);
      return null;
    }
    state = AsyncValue.data(student);
    return student;
  } catch (e, stackTrace) {
    state = AsyncValue.error(e.toString(), stackTrace);
    rethrow;
  }
}

  // Provider để cập nhật thông tin sinh viên
  Future<void> updateStudent({
    required int userId,
    required String mssv,
    required int donviId,
    required int nganhId,
    required int classId,
    required String khoa,
  }) async {
    state = const AsyncValue.loading();
    try {
      final student = await repository.updateStudent(
        userId: userId,
        mssv: mssv,
        donviId: donviId,
        nganhId: nganhId,
        classId: classId,
        khoa: khoa,
      );
      state = AsyncValue.data(student);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      rethrow;
    }
  }
}
