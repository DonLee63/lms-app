import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/survey_repository.dart';

// Provider cho SurveyRepository
final surveyRepositoryProvider = Provider<SurveyRepository>((ref) {
  return SurveyRepository();
});

// Provider để lấy thông tin khảo sát và danh sách câu hỏi
final surveyProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  final hocphanId = params['hocphanId']!;
  final studentId = params['studentId']!;
  final repository = ref.read(surveyRepositoryProvider);
  return repository.getSurvey(hocphanId, studentId);
});

// Provider để gửi kết quả khảo sát
final submitSurveyProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final hocphanId = params['hocphanId']! as int;
  final studentId = params['studentId']! as int;
  final answers = params['answers']! as List<Map<String, dynamic>>;
  final repository = ref.read(surveyRepositoryProvider);
  return repository.submitSurvey(hocphanId, studentId, answers);
});

// Provider để lấy kết quả khảo sát (dành cho giảng viên)
final surveyResultsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  final hocphanId = params['hocphanId']!;
  final giangvienId = params['giangvienId']!;
  final repository = ref.read(surveyRepositoryProvider);
  return repository.getSurveyResults(hocphanId, giangvienId);
});

// Provider để lấy danh sách khảo sát của sinh viên
final studentSurveysProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, studentId) async {
  final repository = ref.read(surveyRepositoryProvider);
  return repository.getStudentSurveys(studentId);
});