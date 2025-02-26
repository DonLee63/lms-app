import 'dart:convert'; // Để xử lý JSON
import 'package:http/http.dart' as http;
// import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teacher.dart';
import '../constants/apilist.dart';
import '../constants/pref_data.dart';

class TeacherRepository {
  Future<Teacher?> createTeacher({
  required String mgv,
  required int maDonvi,
  required int userId,
  required int chuyenNganh, // Khóa ngoại, kiểu int
  String? hocHam, // Có thể null
  String? hocVi, // Có thể null
  required String loaiGiangvien,
}) async {
  try {
    // Lấy token từ PrefData
    final token = await PrefData.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Tạo request body
    final requestBody = {
      "mgv": mgv,
      "ma_donvi": maDonvi,
      "user_id": userId,
      "chuyen_nganh": chuyenNganh, // ID chuyên ngành
      "hoc_ham": hocHam,
      "hoc_vi": hocVi,
      "loai_giangvien": loaiGiangvien,
    };

    print('Request body: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse(api_teacher),
      headers: headers,
      body: json.encode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Xử lý lỗi phiên hết hạn (302)
    if (response.statusCode == 302) {
      await PrefData.clearUserData(); 
      throw Exception('Session expired. Please login again.');
    }

    // Xử lý thành công (201 hoặc 200)
    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final teacher = Teacher.fromJson(responseData['data']);

      // Lưu teacher_id vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('teacher_id', teacher.id);

      print('Teacher ID saved: ${teacher.id}');
      return teacher;
    } 
    
    // Xử lý lỗi xác thực (422)
    else if (response.statusCode == 422) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Validation failed';
      throw Exception(errorMessage);
    } 
    
    // Xử lý các lỗi khác
    else {
      throw Exception('Failed to create teacher. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error creating teacher: $e');
    rethrow;
  }
}
  Future<Teacher?> showTeacher(int userId) async {
  try {
    final token = await PrefData.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$api_teacher/$userId'),
      headers: headers,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final teacher = Teacher.fromJson(responseData['data']);
       // Lưu student_id vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('teacher_id', teacher.id);  // Giả định rằng `student.id` là `int`
      if (responseData['data'] == null) {
        print('Teacher data is null.');
        return null;
      }
      return Teacher.fromJson(responseData['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Teacher not found.');
    } else {
      throw Exception('Failed to fetch teacher details.');
    }
  } catch (e) {
    print('Error fetching teacher: $e');
    rethrow;
  }
}

// Cập nhật thông tin giảng viên
Future<Teacher?> updateTeacher({
  required int userId,
  required String mgv,
  required int donviId,
  required int chuyennganhId,
  required String hocHam,
  required String hocVi,
  required String loaiGiangvien,
}) async {
  try {
    final token = await PrefData.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final requestBody = {
      "mgv": mgv,
      "ma_donvi": donviId,
      "chuyen_nganh": chuyennganhId,
      "hoc_ham": hocHam,
      "hoc_vi": hocVi,
      "loai_giangvien": loaiGiangvien,
    };

    print('Request body: ${json.encode(requestBody)}');

    final response = await http.put(
      Uri.parse('$api_teacher/$userId'), // Thay $teacherId thành $userId trong URL
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
      return Teacher.fromJson(responseData['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Teacher not found.');
    } else {
      throw Exception('Failed to update teacher.');
    }
  } catch (e) {
    print('Error updating teacher: $e');
    rethrow;
  }
}
}