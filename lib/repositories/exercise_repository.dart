import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart';
import '../models/trac_nghiem_question.dart';
import '../models/essay_question.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/models/quiz.dart'; // Import model Quiz

class ExerciseRepository {
  final String baseUrl = base;

  // Tạo câu hỏi trắc nghiệm
  Future<TracNghiemCauhoi> createQuestion(TracNghiemCauhoi question) async {
  final url = Uri.parse('$baseUrl/questions');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token'); // Lấy token
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    },
    body: jsonEncode(question.toJson()),
  );

  print("Request URL: $url");
  print("Request headers: ${{
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  }}");
  print("Request body: ${jsonEncode(question.toJson())}");
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return TracNghiemCauhoi.fromJson(data['data']);
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi tạo câu hỏi: ${response.statusCode} - ${response.body}");
}

  // Tạo đáp án
  Future<TracNghiemDapan> createAnswer(TracNghiemDapan answer) async {
    final url = Uri.parse('$baseUrl/answers');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(answer.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return TracNghiemDapan.fromJson(data['data']);
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi tạo đáp án: ${response.statusCode} - ${response.body}");
  }

  // Tạo đề thi trắc nghiệm
  Future<BodeTracNghiem> createQuiz(BodeTracNghiem quiz) async {
    final url = Uri.parse('$baseUrl/quiz');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(quiz.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return BodeTracNghiem.fromJson(data['data']);
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi tạo đề thi: ${response.statusCode} - ${response.body}");
  }

  // Lấy danh sách câu hỏi theo học phần và user_id
  Future<List<TracNghiemCauhoi>> getQuestionsByHocphan(int hocphanId, int userId) async {
    final url = Uri.parse('$baseUrl/getQuestions?hocphan_id=$hocphanId&user_id=$userId');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => TracNghiemCauhoi.fromJson(item))
            .toList();
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi lấy danh sách câu hỏi: ${response.statusCode} - ${response.body}");
  }

  Future<List<TracNghiemLoai>> getQuestionTypes() async {
  final url = Uri.parse('$baseUrl/question-types');
  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => TracNghiemLoai.fromJson(item))
          .toList();
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi lấy danh sách loại câu hỏi: ${response.statusCode} - ${response.body}");
}
// Tạo câu hỏi tự luận
Future<TuluanCauhoi> createEssayQuestion(TuluanCauhoi question) async {
  final url = Uri.parse('$baseUrl/essay-questions');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(question.toJson()),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return TuluanCauhoi.fromJson(data['data']);
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi tạo câu hỏi tự luận: ${response.statusCode} - ${response.body}");
}

// Tạo bộ đề tự luận
Future<BodeTuluan> createEssayQuiz(BodeTuluan quiz) async {
  final url = Uri.parse('$baseUrl/essay-quiz');
  final body = jsonEncode(quiz.toJson());
  print("Request body: $body"); // Log để kiểm tra

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return BodeTuluan.fromJson(data['data']);
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi tạo bộ đề tự luận: ${response.statusCode} - ${response.body}");
}

// Lấy danh sách câu hỏi tự luận theo học phần
Future<List<TuluanCauhoi>> getEssayQuestionsByHocphan(int hocphanId, int userId) async {
  final url = Uri.parse('$baseUrl/essay-questions-by-hocphan?hocphan_id=$hocphanId&user_id=$userId');
  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List).map((item) => TuluanCauhoi.fromJson(item)).toList();
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi lấy danh sách câu hỏi tự luận: ${response.statusCode} - ${response.body}");
}

Future<List<Quiz>> getTeacherQuizzes(int userId, int hocphanId) async {
  final url = Uri.parse('$baseUrl/teacher-quizzes?user_id=$userId&hocphan_id=$hocphanId');
  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List).map((item) => Quiz.fromJson(item)).toList();
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi lấy danh sách bộ đề: ${response.statusCode} - ${response.body}");
}
Future<Assignment> assignQuiz(Assignment assignment, int userId) async {
  final url = Uri.parse('$baseUrl/assign-quiz');
  final body = jsonEncode({
    ...assignment.toJson(),
    'user_id': userId,
  });

  print("Assign quiz request: $body");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  print("Assign quiz response: ${response.body}");

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return Assignment.fromJson(data['data']);
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi giao bộ đề: ${response.statusCode} - ${response.body}");
}

Future<List<HocphanAssignments>> getStudentAssignments(int studentId) async {
  final url = Uri.parse('$baseUrl/student-assignments?student_id=$studentId');
  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List).map((item) => HocphanAssignments.fromJson(item)).toList();
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi lấy danh sách bài tập: ${response.statusCode} - ${response.body}");
}

Future<List<QuizQuestion>> getTracNghiemQuestions(int assignmentId) async {
    final url = Uri.parse('$baseUrl/trac-nghiem-questions?assignment_id=$assignmentId');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data']['questions'] as List)
            .map((q) => QuizQuestion.fromJson(q))
            .toList();
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi lấy câu hỏi trắc nghiệm: ${response.statusCode} - ${response.body}");
  }

  Future<void> submitTracNghiemQuiz(int studentId, int assignmentId, List<Map<String, int>> answers) async {
    final url = Uri.parse('$baseUrl/submit-trac-nghiem-quiz');
    final body = jsonEncode({
      'student_id': studentId,
      'assignment_id': assignmentId,
      'answers': answers,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return;
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi nộp bài: ${response.statusCode} - ${response.body}");
  }

  Future<List<QuizQuestion>> getTuLuanQuestions(int assignmentId) async {
    final url = Uri.parse('$baseUrl/tu-luan-questions?assignment_id=$assignmentId');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data']['questions'] as List)
            .map((q) => QuizQuestion.fromJson(q))
            .toList();
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi lấy câu hỏi tự luận: ${response.statusCode} - ${response.body}");
  }

  Future<void> submitTuLuanQuiz(int studentId, int assignmentId, List<Map<String, dynamic>> answers) async {
    final url = Uri.parse('$baseUrl/submit-tu-luan-quiz');
    final body = jsonEncode({
      'student_id': studentId,
      'assignment_id': assignmentId,
      'answers': answers,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return;
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi nộp bài: ${response.statusCode} - ${response.body}");
  }

  Future<List<Submission>> getAssignmentSubmissions(int assignmentId) async {
    final url = Uri.parse('$baseUrl/assignment-submissions?assignment_id=$assignmentId');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data']['submissions'] as List)
            .map((s) => Submission.fromJson(s))
            .toList();
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi lấy danh sách bài nộp: ${response.statusCode} - ${response.body}");
  }

  Future<List<Assignment>> getTeacherAssignments(int userId, int hocphanId) async {
  final url = Uri.parse('$baseUrl/teacher-assignments?user_id=$userId&hocphan_id=$hocphanId');
  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List).map((item) => Assignment.fromJson(item)).toList();
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi lấy danh sách bài tập: ${response.statusCode} - ${response.body}");
}

Future<void> deleteQuiz(int userId, int quizId, String quizType) async {
  final url = Uri.parse('$baseUrl/teacher-quiz?user_id=$userId&quiz_id=$quizId&quiz_type=$quizType');
  final response = await http.delete(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return;
    }
    throw Exception(data['message']);
  }
  throw Exception("Lỗi khi xóa bộ đề: ${response.statusCode} - ${response.body}");
}
}