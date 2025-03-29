import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart'; // Đảm bảo file này chứa `base`


class SurveyRepository {

  // Lấy thông tin khảo sát và danh sách câu hỏi
  Future<Map<String, dynamic>> getSurvey(int hocphanId, int studentId) async {
    final url = Uri.parse('$base/surveys/hocphan/$hocphanId?student_id=$studentId');
    print('Requesting URL: $url'); // Debug URL
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    print('Response status: ${response.statusCode}'); // Debug status code
    print('Response body: ${response.body}'); // Debug response body

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load survey: ${response.statusCode}');
    }
  }

  // Gửi kết quả khảo sát
  Future<Map<String, dynamic>> submitSurvey(int hocphanId, int studentId, List<Map<String, dynamic>> answers) async {
    final url = Uri.parse('$base/surveys/hocphan/$hocphanId/submit');
    print('Requesting URL: $url'); // Debug URL
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'answers': answers,
      }),
    );

    print('Response status: ${response.statusCode}'); // Debug status code
    print('Response body: ${response.body}'); // Debug response body

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to submit survey: ${response.statusCode}');
    }
  }

  // Lấy kết quả khảo sát (dành cho giảng viên)
  Future<Map<String, dynamic>> getSurveyResults(int hocphanId, int giangvienId) async {
    final url = Uri.parse('$base/surveys/hocphan/$hocphanId/results?giangvien_id=$giangvienId');
    print('Requesting URL: $url'); // Debug URL
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    print('Response status: ${response.statusCode}'); // Debug status code
    print('Response body: ${response.body}'); // Debug response body

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load survey results: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getStudentSurveys(int studentId) async {
    final url = Uri.parse('$base/surveys/student/$studentId');
    print('Requesting URL: $url'); // Debug URL
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    print('Response status: ${response.statusCode}'); // Debug status code
    print('Response body: ${response.body}'); // Debug response body

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load student surveys: ${response.statusCode}');
    }
  }
}