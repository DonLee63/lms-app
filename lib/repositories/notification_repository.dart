import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_management_app/models/notification.dart';
import '../constants/apilist.dart';

class NotificationRepository {
  final String base;

  NotificationRepository(this.base);

  // Gửi thông báo (cho giảng viên)
  Future<void> sendNotification(int teacherId, int classId, String title, http.MultipartFile file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$base/teacher/send-notification'),
    );

    request.fields['teacher_id'] = teacherId.toString();
    request.fields['class_id'] = classId.toString();
    request.fields['title'] = title;
    request.files.add(file);

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      final data = jsonDecode(responseBody);
      if (data['success']) {
        return;
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi gửi thông báo: ${response.statusCode} - $responseBody");
  }

  // Lấy danh sách thông báo (cho sinh viên)
  Future<List<Notification>> getStudentNotifications(int studentId) async {
    final url = Uri.parse('$base/student/notifications');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'student_id': studentId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => Notification.fromJson(item))
            .toList();
      }
      throw Exception(data['message']);
    }
    throw Exception("Lỗi khi lấy danh sách thông báo: ${response.statusCode} - ${response.body}");
  }
}