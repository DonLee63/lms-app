import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trac_nghiem_question.dart';
import '../constants/apilist.dart'; // Đảm bảo file này chứa `base`

class ExerciseRepository {

  Future<Question?> createQuestion(Question question) async {
    final response = await http.post(
      Uri.parse('$base/questions'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(question.toJson()),
    );

    if (response.statusCode == 200) {
      return Question.fromJson(jsonDecode(response.body)['data']);
    }
    return null;
  }

  Future<Answer?> createAnswer(Answer answer) async {
    final response = await http.post(
      Uri.parse('$base/answers'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(answer.toJson()),
    );

    if (response.statusCode == 200) {
      return Answer.fromJson(jsonDecode(response.body)['data']);
    }
    return null;
  }

  Future<Quiz?> createQuiz(Quiz quiz) async {
    final response = await http.post(
      Uri.parse('$base/quizzes'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(quiz.toJson()),
    );

    if (response.statusCode == 200) {
      return Quiz.fromJson(jsonDecode(response.body)['data']);
    }
    return null;
  }
}
