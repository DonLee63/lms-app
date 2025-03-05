import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/exercise_repository.dart';
import '../models/trac_nghiem_question.dart';

// Provider cho repository
final exerciseRepositoryProvider = Provider((ref) => ExerciseRepository());

// Provider tạo câu hỏi
final createQuestionProvider = FutureProvider.family<TracNghiemCauhoi, TracNghiemCauhoi>((ref, question) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.createQuestion(question);
});

// Provider tạo đáp án
final createAnswerProvider = FutureProvider.family<TracNghiemDapan, TracNghiemDapan>((ref, answer) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.createAnswer(answer);
});

// Provider tạo đề thi
final createQuizProvider = FutureProvider.family<BodeTracNghiem, BodeTracNghiem>((ref, quiz) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.createQuiz(quiz);
});

// Provider lấy danh sách câu hỏi theo học phần và user_id
final questionsByHocphanProvider = FutureProvider.family<List<TracNghiemCauhoi>, Map<String, int>>((ref, params) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.getQuestionsByHocphan(params['hocphan_id']!, params['user_id']!);
});