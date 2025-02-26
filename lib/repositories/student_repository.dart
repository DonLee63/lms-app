import 'dart:convert'; // Để xử lý JSON
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../constants/apilist.dart';
import '../constants/pref_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentRepository {
 Future<Student?> createStudent({
  required String mssv,
  required int donviId,
  required int nganhId,
  required int classId,
  required String khoa,
  required int userId,
}) async {
  try {
    final token = await PrefData.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final requestBody = {
      "mssv": mssv,
      "donvi_id": donviId,
      "nganh_id": nganhId,
      "class_id": classId,
      "khoa": khoa,
      "user_id": userId,
    };

    final response = await http.post(
      Uri.parse(api_student),
      headers: headers,
      body: json.encode(requestBody),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final student = Student.fromJson(responseData['data']);

      // Lưu student_id vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('student_id', student.id);  // Giả định rằng `student.id` là `int`

      print('Student ID saved: ${student.id}');
      return student;
    } else if (response.statusCode == 422) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Validation failed';
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to create student. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error creating student: $e');
    rethrow;
  }
}
  
  // Lấy thông tin sinh viên theo userId
Future<Student?> showStudent(int userId) async {
  try {
    final token = await PrefData.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$api_student/$userId'),
      headers: headers,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Kiểm tra nếu `data` là null
      if (responseData['data'] == null) {
        print('Student data is null.');
        return null; // Trả về null nếu không có dữ liệu
      }
      return Student.fromJson(responseData['data']);
    } else if (response.statusCode == 404) {
      print('Student not found for userId: $userId');
      return null; // Trả về null nếu không tìm thấy sinh viên
    } else {
      throw Exception('Failed to fetch student details. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching student: $e');
    rethrow;
  }
}


// Cập nhật thông tin sinh viên
Future<Student?> updateStudent({
  required int userId,
  required String mssv,
  required int donviId,
  required int nganhId,
  required int classId,
  required String khoa,
}) async {
  try {
    final token = await PrefData.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final requestBody = {
      "mssv": mssv,
      "donvi_id": donviId,
      "nganh_id": nganhId,
      "khoa": khoa,
    };

    print('Request body: ${json.encode(requestBody)}');

    final response = await http.put(
      Uri.parse('$api_student/$userId'), // Thay $studentId thành $userId trong URL
      headers: headers,
      body: json.encode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 422) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Validation failed';
      final errors = errorData['errors'];

      if (errors != null && errors is Map) {
        final List<String> errorMessages = [];
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.cast<String>());
          }
        });
        throw Exception(errorMessages.join('\n'));
      }

      throw Exception(errorMessage);
    }

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Student.fromJson(responseData['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Student not found.');
    } else {
      throw Exception('Failed to update student.');
    }
  } catch (e) {
    print('Error updating student: $e');
    rethrow;
  }
}
}
