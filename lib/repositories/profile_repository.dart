import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/apilist.dart';
import '../constants/pref_data.dart';
import '../models/profile.dart';

class ProfileRepository {
  final String apiUrl = api_updateprofile; // URL của API

  Future<bool> updateProfile(Profile profile) async {
  try {
    // Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(PrefData.token); // Lấy token từ key PrefData.token

    if (token == null) {
      print('Token is null. Cannot update profile.');
      return false; // Không có token, không thể cập nhật
    }

    // Thực hiện yêu cầu HTTP
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Đính kèm token
      },
      body: jsonEncode(profile.toJson()),
    );

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      return true; // Cập nhật thành công
    } else {
      print('Failed to update profile: ${response.body}');
      return false; // Thất bại
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}


  Future<Profile?> getProfile() async {
    try {
// Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(PrefData.token); // Lấy token từ key PrefData.token

    if (token == null) {
      print('Token is null. Cannot update profile.');
    }

      final response = await http.get(
        Uri.parse('$base/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['profile'];
        if (userData == null) {
          print('No user data found in response');
          return null;
        }
        
        return Profile(
          id: userData['id'], // Assuming 'id' is present in userData
          email: userData['email'] ?? '',
          full_name: userData['full_name'] ?? '',
          phone: userData['phone'] ?? '',
          address: userData['address'] ?? '',
          photo: userData['photo'] ?? '', 
          username: userData['username'] ?? '', 
        );
      }
      return null;
    } catch (e, stackTrace) {
      print('Error in getProfile: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<String?> uploadPhoto(File photoFile) async {
    try {

      // Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(PrefData.token); // Lấy token từ key PrefData.token

    if (token == null) {
      print('Token is null. Cannot update profile.');
    }

      final url = Uri.parse('$base/upload-photo');
      
      var request = http.MultipartRequest('POST', url);
      
      var photo = await http.MultipartFile.fromPath('photo', photoFile.path);
      request.files.add(photo);
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      });
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['photo_url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload photo: $e');
    }
  }
}
