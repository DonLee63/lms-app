import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/apilist.dart'; // Đảm bảo file này chứa `base`

class AttendanceRepository {
  // Giảng viên mở điểm danh
  Future<void> startAttendance(int tkbId, int duration) async {
    final url = Uri.parse("$base/startAttendance");

    // Lấy teacher_id từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getInt('teacher_id'); // Giả định teacher_id được lưu dưới dạng int

    if (teacherId == null) {
      throw Exception("Không tìm thấy teacher_id trong SharedPreferences");
    }

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tkb_id": tkbId,
        "duration": duration, // Thời gian điểm danh (phút)
        "teacher_id": teacherId, // Lấy từ SharedPreferences
      }),
    );

    if (response.statusCode == 200) {
      print("Mở điểm danh thành công!");
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception("Lỗi khi mở điểm danh: ${errorData['message'] ?? response.body}");
    }
  }

  // Sinh viên điểm danh
  Future<void> markAttendance(int tkbId, int studentId) async {
    final url = Uri.parse("$base/markAttendance");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tkb_id": tkbId,
        "student_id": studentId,
      }),
    );

    if (response.statusCode == 200) {
      print("Điểm danh thành công!");
    } else {
      final errorData = jsonDecode(response.body);
      print("Error: ${response.body}");
      print("Status code: ${response.statusCode}");
      throw Exception("Lỗi khi điểm danh: ${errorData['message'] ?? response.body}");
    }
  }
  // Giảng viên đóng điểm danh và xác định sinh viên vắng
  Future<List<int>> closeAttendance(int tkbId, List<int> studentIds) async {
    final url = Uri.parse("$base/closeAttendance");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tkb_id": tkbId,
        "student_ids": studentIds, // Danh sách toàn bộ sinh viên trong lớp
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<int>.from(data['absent_list']);
    } else {
      throw Exception("Lỗi khi đóng điểm danh: ${response.body}");
    }
  }

Future<Map<String, dynamic>> getAttendanceList(int tkbId) async {
  final url = Uri.parse("$base/getAttendanceBySchedule?tkb_id=$tkbId");

  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final studentList = data['data']['student_list'] as List<dynamic>;
      final presentList = studentList
          .where((student) => student['status'] == 'present')
          .map((student) => {
                'student_id': student['student_id'],
                'mssv': student['mssv'],
                'full_name': student['full_name'],
              })
          .toList();
      final absentList = studentList
          .where((student) => student['status'] == 'absent')
          .map((student) => {
                'student_id': student['student_id'],
                'mssv': student['mssv'],
                'full_name': student['full_name'],
              })
          .toList();

      return {
        "present": presentList,
        "absent": absentList,
        "is_open": data['data']['is_open'] ?? false, // Lấy is_open từ API
      };
    } else {
      throw Exception("API trả về thất bại: ${data['message']}");
    }
  } else {
    print("${response.body}");
    print("${response.statusCode}");
    throw Exception("Lỗi khi lấy danh sách điểm danh: ${response.body}");
  }
}
}
