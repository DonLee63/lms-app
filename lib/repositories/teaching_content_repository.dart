import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_management_app/constants/apilist.dart';
import 'package:study_management_app/models/teaching_content.dart';

class TeachingContentRepository {
  // API để giảng viên gửi nội dung giảng dạy
  Future<Map<String, dynamic>> sendTeachingContent({
    required int teacherId,
    required int phancongId,
    required String title,
    required String filePath,
  }) async {
    final url = Uri.parse('$base/send-teaching-content');
    var request = http.MultipartRequest('POST', url);

    // Thêm các trường vào request
    request.fields['teacher_id'] = teacherId.toString();
    request.fields['phancong_id'] = phancongId.toString();
    request.fields['title'] = title;

    // Thêm file vào request
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    // Gửi request
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (response.statusCode == 201) {
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to send teaching content: ${response.statusCode} - ${data['message']}');
    }
  }

  // API để sinh viên lấy danh sách nội dung giảng dạy
  Future<List<TeachingContent>> getTeachingContent(int studentId, int phancongId) async {
    final url = Uri.parse('$base/get-teaching-content');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_id': studentId,
        'phancong_id': phancongId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> contentList = data['data'];
        return contentList.map((json) => TeachingContent.fromJson(json)).toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load teaching content: ${response.statusCode} - ${response.body}');
    }
  }
}