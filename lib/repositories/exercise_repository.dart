import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart';
import '../models/trac_nghiem_question.dart';
import '../models/essay_question.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/models/quiz.dart'; // Import model Quiz
import 'package:flutter/material.dart';

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

Future<Map<String, dynamic>> getAssignmentSubmissions(int assignmentId) async {
  try {
    final response = await http.get(
      Uri.parse('$base/assignment-submissions/$assignmentId'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load submissions: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getAssignmentSubmissions: $e');
    rethrow;
  }
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

Future<void> deleteAssignment(int userId, int assignmentId) async {
  final url = Uri.parse('$base/delete-assignment');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'user_id': userId,
      'assignment_id': assignmentId,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message']);
    }
  } else {
    throw Exception('Failed to delete assignment: ${response.statusCode} - ${response.body}');
  }
}

Future<void> updateSubmissionScore(int userId, int submissionId, double score) async {
    final url = Uri.parse('$base/update-submission-score');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'submission_id': submissionId,
        'score': score,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] != true) {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to update submission score: ${response.statusCode} - ${response.body}');
    }
  }
  Future<Map<String, dynamic>> getStudentAverageScores(int hocphanId) async {
    final url = Uri.parse('$base/hocphan/$hocphanId/avg-scores');
    print('Requesting URL: $url'); // Debug URL
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    print('Response status: ${response.statusCode}'); // Debug status code
    print('Response body: ${response.body}'); // Debug response body

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load average scores: ${response.statusCode}');
    }
  }

  // Xóa câu hỏi trắc nghiệm
  Future<void> deleteQuestion(int questionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$base/questions/$questionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Thêm header nếu cần, ví dụ: Authorization
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi xóa câu hỏi trắc nghiệm');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Xóa câu hỏi tự luận
  Future<void> deleteEssayQuestion(int questionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$base/essay-questions/$questionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Thêm header nếu cần, ví dụ: Authorization
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi xóa câu hỏi tự luận');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

// Fetch multiple-choice quiz by ID
  Future<BodeTracNghiem> getQuizById(int quizId) async {
    final response = await http.get(
      Uri.parse('$base/show-quizzes/$quizId'),
      headers: {'Accept': 'application/json'},
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      debugPrint('Parsed JSON: $json');
      if (json['success'] == true) {
        final quizData = json['data'];
        debugPrint('Quiz data for parsing: $quizData');
        final quiz = BodeTracNghiem.fromJson(quizData);
        debugPrint('Parsed quiz: title=${quiz.title}, questions=${quiz.questions}');
        return quiz;
      } else {
        throw Exception(json['message']);
      }
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy bộ đề trắc nghiệm');
    } else {
      throw Exception('Lỗi khi tải bộ đề trắc nghiệm: ${response.statusCode}');
    }
  }

  // Fetch essay quiz by ID
  Future<BodeTuluan> getEssayQuizById(int quizId) async {
    final response = await http.get(
      Uri.parse('$base/show-essay-quizzes/$quizId'),
      headers: {'Accept': 'application/json'},
    );

    print('Response status: ${response.statusCode}'); // Debug status code
    print('Response body: ${response.body}'); // Debug response body

   if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      debugPrint('Parsed JSON: $json');
      if (json['success'] == true) {
        final quizData = json['data'];
        debugPrint('Quiz data for parsing: $quizData');
        final quiz = BodeTuluan.fromJson(quizData);
        debugPrint('Parsed quiz: title=${quiz.title}, questions=${quiz.questions}');
        return quiz;
      } else {
        throw Exception(json['message']);
      }
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy bộ đề trắc nghiệm');
    } else {
      throw Exception('Lỗi khi tải bộ đề trắc nghiệm: ${response.statusCode}');
    }
  }

  // Update multiple-choice quiz
  Future<BodeTracNghiem> updateQuiz(BodeTracNghiem quiz) async {
    final response = await http.put(
      Uri.parse('$base/edit-quizzes/${quiz.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'title': quiz.title,
        'hocphan_id': quiz.hocphanId,
        'start_time': quiz.startTime.toIso8601String(),
        'end_time': quiz.endTime.toIso8601String(),
        'time': quiz.time,
        'total_points': quiz.totalPoints,
        'questions': quiz.questions,
        'user_id': quiz.userId,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return BodeTracNghiem.fromJson(json['data']);
      } else {
        throw Exception(json['message']);
      }
    } else if (response.statusCode == 422) {
      final json = jsonDecode(response.body);
      throw Exception('Validation failed: ${json['errors'].toString()}');
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy bộ đề trắc nghiệm');
    } else {
      throw Exception('Lỗi khi cập nhật bộ đề trắc nghiệm: ${response.statusCode}');
    }
  }

  // Update essay quiz
  Future<BodeTuluan> updateEssayQuiz(BodeTuluan quiz) async {
    final response = await http.put(
      Uri.parse('$base/edit-essay-quizzes/${quiz.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'title': quiz.title,
        'hocphan_id': quiz.hocphanId,
        'start_time': quiz.startTime.toIso8601String(),
        'end_time': quiz.endTime.toIso8601String(),
        'time': quiz.time,
        'total_points': quiz.totalPoints,
        'questions': quiz.questions,
        'user_id': quiz.userId,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return BodeTuluan.fromJson(json['data']);
      } else {
        throw Exception(json['message']);
      }
    } else if (response.statusCode == 422) {
      final json = jsonDecode(response.body);
      throw Exception('Validation failed: ${json['errors'].toString()}');
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy bộ đề tự luận');
    } else {
      throw Exception('Lỗi khi cập nhật bộ đề tự luận: ${response.statusCode}');
    }
  }
}