import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart'; // Đảm bảo file này chứa `base`

class AttendanceRepository {
  // Giảng viên mở điểm danh
  Future<void> startAttendance(int tkbId, int duration) async {
    final url = Uri.parse("$base/startAttendance");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tkb_id": tkbId,
        "duration": duration, // Thời gian điểm danh (phút)
      }),
    );

    if (response.statusCode == 200) {
      print("Mở điểm danh thành công!");
    } else {
      throw Exception("Lỗi khi mở điểm danh: ${response.body}");
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
        "student_id": studentId, // Đổi từ "user_id" thành "student_id"
      }),
    );

    if (response.statusCode == 200) {
      print("Điểm danh thành công!");
    } else {
       print("${response.body}");
       print("${response.statusCode}");
      throw Exception("Lỗi điểm danh: ${response.body}");
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
        // Lấy danh sách sinh viên từ student_list
        final studentList = data['data']['student_list'] as List<dynamic>;

        // Tách danh sách thành present và absent dựa trên status
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
