import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/pref_data.dart';
import '../constants/apilist.dart';
import '../models/user.dart';
// import '../models/profile.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final String apiUrl = api_login;

  // Login method
  Future<bool> login(String username, String password) async {
    try {
      final response = await Dio().post(
        api_login,
        data: {
          'email': username,
          'password': password,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Full response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Trích xuất token
        final tokenData = response.data['token'];
        final String? token = tokenData['token'];
        // Trích xuất user data nếu có
        final userData = response.data['user'];
        final userId = response.data['user']['id']; // Lấy userId
        final role = response.data['user']['role']; // Lấy role
        final student_id = response.data['student_id']; // Lấy role
        final teacher_id = response.data['teacher_id']; // Lấy role
        print(userId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
        await prefs.setString('role', role);
        await prefs.setInt('student_id', student_id);
        await prefs.setInt('teacher_id', teacher_id);
        print('Extracted token: $token');
        print('User data: $userData');

        if (token != null && token.isNotEmpty) {
          await PrefData.saveLoginState(token, userData);
          return true;
        } else {
          print('Token was null or empty in response');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

Future<Map<String, dynamic>> register(User user) async {
  try {
    final response = await http.post(
      Uri.parse(api_register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['user']['id']; // Lấy userId
      final role = data['user']['role']; // Lấy userId
      final token = data['token'];       // Lấy token
      // Lưu userId vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);
      await prefs.setString('role', role);
      await prefs.setString('token', token);
      return {'userId': userId, 'token': token}; // Trả về cả userId và token
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Đăng ký thất bại.');
    }
  } catch (error) {
    print('Registration error: $error');
    rethrow;
  }
}



  // Logout method
Future<bool> logout() async {
  try {
    final token = await PrefData.getToken();
    print(token);
    // Check if token exists
    if (token == null || token.isEmpty) {
      print('No token found. User is already logged out.');
     await PrefData.clearUserData(); // Clear local data in both cases
      return true;
    }

    try {
      final response = await Dio().post(
        api_logout,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          // Allow 401 status to be handled without throwing
          validateStatus: (status) => status! < 500,
        ),
      );

      // Handle both successful logout and 401 unauthorized
      if (response.statusCode == 200 || response.statusCode == 401) {
        await PrefData.clearUserData(); // Clear local data in both cases
        return true;
      } else {
        print('Logout failed with status: ${response.statusCode}');
        print('Response data: ${response.data}');
        return false;
      }
    } on DioException catch (dioError) {
      print('Dio error during logout: ${dioError.message}');
      // If we get a 401, still clear local data
      if (dioError.response?.statusCode == 401) {
      await PrefData.clearUserData(); // Clear local data in both cases
        return true;
      }
      return false;
    }
  } catch (e) {
    print('General error during logout: $e');
    return false;
  }
}

  Future<Dio> getDioClient() async {
    return Dio(BaseOptions(
      baseUrl: apiUrl,
      headers: {'Content-Type': 'application/json'},
    ));
  }
}
