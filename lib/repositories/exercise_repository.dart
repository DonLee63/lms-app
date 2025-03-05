import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart';
import '../models/trac_nghiem_question.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}