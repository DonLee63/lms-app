import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/exercise_repository.dart';
import '../models/trac_nghiem_question.dart';
import '../models/essay_question.dart';
import 'package:study_management_app/models/quiz.dart'; // Import model Quiz và Submission

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

// Provider lấy danh sách loại câu hỏi
final questionTypesProvider = FutureProvider<List<TracNghiemLoai>>((ref) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.getQuestionTypes();
});

// Provider tạo câu hỏi tự luận
final createEssayQuestionProvider = FutureProvider.family<TuluanCauhoi, TuluanCauhoi>((ref, question) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.createEssayQuestion(question);
});

// Provider tạo bộ đề tự luận
final createEssayQuizProvider = FutureProvider.family<BodeTuluan, BodeTuluan>((ref, quiz) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.createEssayQuiz(quiz);
});

// Provider lấy danh sách câu hỏi tự luận theo học phần
final essayQuestionsByHocphanProvider = FutureProvider.family<List<TuluanCauhoi>, Map<String, int>>((ref, params) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.getEssayQuestionsByHocphan(params['hocphan_id']!, params['user_id']!);
});

// Provider lấy danh sách bài tập của giảng viên
final teacherQuizzesProvider = FutureProvider.family<List<Quiz>, Map<String, int>>((ref, params) async {
  final repository = ref.read(exerciseRepositoryProvider);
  final userId = params['userId']!;
  final hocphanId = params['hocphanId']!;
  return await repository.getTeacherQuizzes(userId, hocphanId);
});

// Provider giao bài tập
final assignQuizProvider = FutureProvider.family<Assignment, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(exerciseRepositoryProvider);
  final assignment = params['assignment'] as Assignment;
  final userId = params['userId'] as int;
  return await repository.assignQuiz(assignment, userId);
});

// Provider lấy danh sách bài tập của sinh viên
final studentAssignmentsProvider = FutureProvider.family<List<HocphanAssignments>, int>((ref, studentId) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.getStudentAssignments(studentId);
});

// Provider lấy danh sách câu hỏi trắc nghiệm
final tracNghiemQuestionsProvider = FutureProvider.family<List<QuizQuestion>, int>((ref, assignmentId) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.getTracNghiemQuestions(assignmentId);
});

// Provider lấy danh sách câu hỏi tự luận
final tuLuanQuestionsProvider = FutureProvider.family<List<QuizQuestion>, int>((ref, assignmentId) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return await repository.getTuLuanQuestions(assignmentId);
});

final assignmentSubmissionsProvider = FutureProvider.family<List<Submission>, int>((ref, assignmentId) async {
  final repository = ref.read(exerciseRepositoryProvider);
  final response = await repository.getAssignmentSubmissions(assignmentId);

  // Debug response
  print('API Response: $response');

  // Lấy data từ response
  final data = response['data'] as Map<String, dynamic>?;

  if (data == null) {
    throw Exception('Response data is null');
  }

  final quizType = data['quiz_type'] as String? ?? 'tu_luan';
  print('Parsed quizType: $quizType'); // Debug quizType

  final submissionsJson = data['submissions'] as List<dynamic>? ?? [];
  return submissionsJson.map((submission) => Submission.fromJson(submission, quizType)).toList();
});

// Provider để cập nhật điểm số bài nộp
final updateSubmissionScoreProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(exerciseRepositoryProvider);
  final userId = params['userId'] as int;
  final submissionId = params['submissionId'] as int;
  final score = params['score'] as double;
  await repository.updateSubmissionScore(userId, submissionId, score);
});

// Provider để lấy điểm trung bình của tất cả sinh viên trong học phần
final studentAverageScoresProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, hocphanId) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return repository.getStudentAverageScores(hocphanId);
});

final deleteQuestionProvider = FutureProvider.family<void, int>((ref, questionId) async {
  final repository = ref.read(exerciseRepositoryProvider);
  await repository.deleteQuestion(questionId);
});

// Provider để xóa câu hỏi tự luận
final deleteEssayQuestionProvider = FutureProvider.family<void, int>((ref, questionId) async {
  final repository = ref.read(exerciseRepositoryProvider);
  await repository.deleteEssayQuestion(questionId);
});