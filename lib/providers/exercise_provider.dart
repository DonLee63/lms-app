import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/exercise_repository.dart';
import '../models/trac_nghiem_question.dart';

final exerciseRepositoryProvider = Provider((ref) => ExerciseRepository());

final createQuestionProvider = FutureProvider.family<Question?, Question>((ref, question) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return repository.createQuestion(question);
});

final createAnswerProvider = FutureProvider.family<Answer?, Answer>((ref, answer) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return repository.createAnswer(answer);
});

final createQuizProvider = FutureProvider.family<Quiz?, Quiz>((ref, quiz) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return repository.createQuiz(quiz);
});
