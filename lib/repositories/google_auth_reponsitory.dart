import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:study_management_app/constants/apilist.dart';

class GoogleAuthRepository {
  final String apiUrl = api_loginGoogle;

  Future<Map<String, dynamic>> signUpWithGoogle({required String role}) async {
  try {
    // Đăng nhập bằng Google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return {"error": "Sign in aborted by user"};
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Đăng nhập Firebase
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user == null) {
      return {"error": "Failed to retrieve user"};
    }

    // Gửi thông tin user tới Laravel API, bao gồm role mà người dùng chọn
    final response = await http.post(
      Uri.parse(apiUrl),  // Đảm bảo apiUrl là URL API Laravel của bạn
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': user.email,
        'full_name': user.displayName,
        'google_id': user.uid,
        'role': role,  // Gửi role mà người dùng chọn
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['user']['id']; // Lấy userId
      final role = data['user']['role']; // Lấy role
      final token = data['token'];       // Lấy token
      
      // Lưu userId, role và token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);
      await prefs.setString('role', role);
      await prefs.setString('token', token);
     

      return {'userId': userId, 'token': token};
    } else {
      print('Response Body: ${response.body}');
      return {
        "error": "Failed to save user to server, status code: ${response.statusCode}"
      };
    }
  } catch (e) {
    return {"error": e.toString()};
  }
}

Future<Map<String, dynamic>> signInWithGoogle() async {
  try {
    // Đăng nhập bằng Google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return {"error": "Sign in aborted by user"};
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Đăng nhập Firebase
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user == null) {
      return {"error": "Failed to retrieve user"};
    }

    // Gửi thông tin user tới Laravel API
    final response = await http.post(
      Uri.parse(apiUrl),  // Đảm bảo apiUrl là URL API Laravel của bạn
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': user.email,
        'full_name': user.displayName,
        'google_id': user.uid,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['user']['id']; // Lấy userId
      final role = data['user']['role']; // Lấy userId
      final token = data['token'];       // Lấy token
      final student_id = data['student_id']; // Lấy role
      final teacher_id = data['teacher_id']; // Lấy role
      // Lưu userId vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);
      await prefs.setString('role', role);
      await prefs.setString('token', token);
       await prefs.setInt('student_id', student_id);
      await prefs.setInt('teacher_id', teacher_id);
      return {'userId': userId, 'token': token};
      // Kiểm tra nếu có lỗi từ API
    } else {
      print('Response Body: ${response.body}');
      return {
        "error": "Failed to save user to server, status code: ${response.statusCode}"
      };
    }
  } catch (e) {
    return {"error": e.toString()};
  }
}

}
