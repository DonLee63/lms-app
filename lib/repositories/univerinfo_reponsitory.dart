import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_management_app/constants/apilist.dart';

import '../models/phan_cong.dart';

class UniverInfoRepository {

  Future<List<Map<String, dynamic>>> fetchNganhs(int donviId) async {
  final url = Uri.parse('$api_nganhs?donvi_id=$donviId'); // Chuyển sang phương thức GET với tham số query string

  try {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách ngành.');
      }
    } else {
      throw Exception('Lỗi HTTP: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Lỗi khi gọi API: $e');
  }
}


  // Hàm lấy danh sách đơn vị
  Future<List<Map<String, dynamic>>> fetchDonVis() async {
    final url = Uri.parse(api_donvi);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']); // Chuyển đổi về List<Map<String, dynamic>>
        } else {
          throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách đơn vị.');
        }
      } else {
        throw Exception('Lỗi HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  // Hàm lấy danh sách chuyen nganh
  Future<List<Map<String, dynamic>>> fetchChuyenNganh() async {
    final url = Uri.parse(api_chuyenNganh);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']); // Chuyển đổi về List<Map<String, dynamic>>
        } else {
          throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách chuyên ngành.');
        }
      } else {
        throw Exception('Lỗi HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

Future<List<Map<String, dynamic>>> fetchClasses(int nganhId) async {
  final url = Uri.parse('$api_classes?nganh_id=$nganhId'); // Chuyển sang phương thức GET với tham số query string

  try {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách lớp.');
      }
    } else {
      throw Exception('Lỗi HTTP: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Lỗi khi gọi API: $e');
  }
}


  Future<List<PhanCong>> fetchPhanCongByTeacherId(int teacherId) async {
    final response = await http.get(
      Uri.parse('$base/phancong?giangvien_id=$teacherId'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        List<dynamic> data = responseData['data'];
        return data.map((json) => PhanCong.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}
