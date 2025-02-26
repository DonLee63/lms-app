import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/teacher_reponsitory.dart';
import '../models/teacher.dart';
import 'dart:async';

final teacherRepositoryProvider = StateNotifierProvider<TeacherNotifier, AsyncValue<Teacher?>>(
  (ref) => TeacherNotifier(TeacherRepository()),
);

class TeacherNotifier extends StateNotifier<AsyncValue<Teacher?>> {
  final TeacherRepository repository;

  TeacherNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> createTeacher({
    required String mgv,
    required int maDonvi,
    required int userId,
    required int chuyenNganh,
    String? hocHam,
    String? hocVi,
    required String loaiGiangvien,
  }) async {
    state = const AsyncValue.loading();
    try {
      final teacher = await repository.createTeacher(
        mgv: mgv,
        maDonvi: maDonvi,
        userId: userId,
        chuyenNganh: chuyenNganh,
        hocHam: hocHam,
        hocVi: hocVi,
        loaiGiangvien: loaiGiangvien,
      );
      state = AsyncValue.data(teacher);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      rethrow;
    }
  }

  // Provider để lấy thông tin sinh viên theo userId
  Future<Teacher?> showTeacher(int userId) async {
    state = const AsyncValue.loading();
    try {
      final teacher = await repository.showTeacher(userId);
      if (teacher == null) {
        print('No teacher found for userId: $userId');
        state = AsyncValue.data(null);
        return null;
      }
      state = AsyncValue.data(teacher);
      return teacher;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      rethrow;
    }
  }

  // Provider để cập nhật thông tin sinh viên
  Future<void> updateTeacher({
    required int userId,
    required String mgv,
    required int donviId,
    required int chuyennganhId,
    required String hocHam,
    required String hocVi,
    required String loaiGiangvien,
  }) async {
    state = const AsyncValue.loading();
    try {
      final student = await repository.updateTeacher(
        userId: userId,
        mgv: mgv,
        donviId: donviId,
        chuyennganhId: chuyennganhId,
        hocHam: hocHam,
        hocVi: hocVi,
        loaiGiangvien: loaiGiangvien,
      );
      state = AsyncValue.data(student);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      rethrow;
    }
  }
}