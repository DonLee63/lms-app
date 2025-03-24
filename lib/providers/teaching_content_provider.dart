import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/models/teaching_content.dart';
import 'package:study_management_app/repositories/teaching_content_repository.dart';

// Provider cho repository
final teachingContentRepositoryProvider = Provider((ref) => TeachingContentRepository());

// Provider để lấy danh sách nội dung giảng dạy (cho sinh viên)
final teachingContentProvider = FutureProvider.family<List<TeachingContent>, Map<String, int>>((ref, params) async {
  final repo = ref.watch(teachingContentRepositoryProvider);
  return repo.getTeachingContent(params['student_id']!, params['phancong_id']!);
});

// Provider để gửi nội dung giảng dạy (cho giảng viên)
final sendTeachingContentProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final repo = ref.watch(teachingContentRepositoryProvider);
  return repo.sendTeachingContent(
    teacherId: params['teacher_id'] as int,
    phancongId: params['phancong_id'] as int,
    title: params['title'] as String,
    filePath: params['file_path'] as String,
  );
});