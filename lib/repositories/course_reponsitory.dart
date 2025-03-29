import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_management_app/models/enrollment.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../constants/apilist.dart'; // Đảm bảo file này chứa `baseUrl`

class CourseRepository {
  Future<Map<String, Map<String, List<Course>>>> getAvailableCourses(int studentId) async {
    final response = await http.get(
      Uri.parse('$base/courses?student_id=$studentId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Group courses by `so_hoc_ky` and `loai`
      final Map<String, Map<String, List<Course>>> groupedCourses = {};

      for (var courseData in data) {
        final course = Course.fromJson(courseData);
        final hocKy = courseData['so_hoc_ky'].toString();
        final loai = courseData['loai']; // "Bắt buộc" hoặc "Tự chọn"

        groupedCourses[hocKy] ??= {'bat_buoc': [], 'tu_chon': []};

        if (loai == 'Bắt buộc') {
          groupedCourses[hocKy]!['bat_buoc']!.add(course);
        } else if (loai == 'Tự chọn') {
          groupedCourses[hocKy]!['tu_chon']!.add(course);
        }
      }

      return groupedCourses;
    } else {
      throw Exception("Failed to load courses");
    }
  }

  Future<String> enrollCourse(int studentId, int phancongId) async {
  final response = await http.post(
    Uri.parse('$base/enroll'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'student_id': studentId,
      'phancong_id': phancongId,
    }),
  );

  if (response.statusCode == 201) {
    return "Đăng ký thành công";
  } else {
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (responseData.containsKey('missing_courses')) {
      // Tạo thông báo với danh sách học phần cần hoàn thành
      String missingCourses = responseData['missing_courses'].join(', ');
      throw Exception("Bạn cần hoàn thành học phần: $missingCourses.");
    }
    throw Exception(responseData['message'] ?? "Failed to enroll in course");
  }
}

Future<List<Enrollment>> getEnrolledCourses(int studentId) async {
  final response = await http.post(
    Uri.parse('$base/getEnroll'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'student_id': studentId}),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    
    // Chuyển đổi từ JSON sang đối tượng Course
    return data.map((json) => Enrollment.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to fetch enrolled courses');
  }
}


  // Xóa học phần theo enrollment_id
  Future<String> deleteEnrollment(int enrollmentId) async {
    final response = await http.post(
      Uri.parse('$base/deleteEnroll'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'enrollment_id': enrollmentId}),
    );

    if (response.statusCode == 200) {
      return "Enrollment deleted successfully";
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? "Failed to delete enrollment");
    }
  }

  Future<List<Course>> searchCourses(int studentId, {String? keyword}) async {
    final queryParams = {
      'student_id': studentId.toString(),
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    };

    final uri = Uri.parse('$base').replace(queryParameters: queryParams);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((course) => Course.fromJson(course)).toList();
    } else {
      throw Exception('Failed to search courses: ${response.reasonPhrase}');
    }
  }

  Future<List<dynamic>> fetchTimetable(int studentId) async {
  final response = await http.get(
    Uri.parse('$base/timeTable?student_id=$studentId'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return data['data'];
    } else {
      throw Exception(data['message']);
    }
  } else {
    throw Exception("Failed to load timetable. Error: ${response.statusCode}");
  }
}

Future<List<dynamic>> fetchTeacherSchedule(int teacherId) async {
    final response = await http.get(
      Uri.parse('$base/lichday?teacher_id=$teacherId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Failed to load schedule. Error: ${response.statusCode}");
    }
  }

Future<List<Map<String, dynamic>>> getStudentExamSchedules(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$base/lichthi?student_id=$studentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception("Failed to load exam schedules");
        }
      } else {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching exam schedules: $e");
    }
  }
  
Future<List<StudentModel>> getClassStudents(int teacherId) async {
    try {
      final response = await http.get(
  Uri.parse('$base/getClass?teacher_id=$teacherId'),
  headers: {'Content-Type': 'application/json'},
);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => StudentModel.fromJson(json)).toList();
      } else {
        // throw Exception('Failed to load students');
         throw Exception("Failed to load student. Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception('Error fetching students: $e');
    }
  }

Future<List<Map<String, dynamic>>> getStudentsByTeacher(int teacherId, int phancongId) async {
  final url = Uri.parse("$base/getListstudentCourse?teacher_id=$teacherId&phancong_id=$phancongId");
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"]) {
        return List<Map<String, dynamic>>.from(data["data"]);
      } else {
        throw Exception(data["message"]);
      }
    } else {
      throw Exception("Failed to load students. Status: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error fetching students: $e");
  }
}

Future<void> updateEnrollmentStatus(int userId, int enrollmentId, String newStatus) async {
    final url = Uri.parse('$base/update-enrollment-status');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'enrollment_id': enrollmentId,
        'status': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] != true) {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to update enrollment status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateStudentScores({
    required int studentId,
    required int hocphanId,
    required double diemBP,
    double? thi1,
    double? thi2,
  }) async {
    final url = Uri.parse('$base/student-scores/$studentId/$hocphanId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'DiemBP': diemBP,
        'Thi1': thi1,
        'Thi2': thi2,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update scores: ${response.body}');
    }
  }


  Future<Map<String, dynamic>> getStudentScores(int studentId, int hocphanId) async {
    final url = Uri.parse('$base/get-student-scores/$studentId/$hocphanId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('Response status: ${response.statusCode}'); // Debug status code
        print('Response body: ${response.body}'); // Debug response body
        return data['data'].isNotEmpty ? data['data'][0] : <String, dynamic>{};
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load scores: ${response.body}');
    }
  }

  // Lấy thông tin tiến độ học tập của sinh viên
  Future<Map<String, dynamic>> getStudentProgress(int studentId) async {
    final url = Uri.parse('$base/student-progress/$studentId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load progress: ${response.body}');
    }
  }

  // Lấy thông tin thống kê và báo cáo cho giảng viên
  Future<Map<String, dynamic>> getTeacherReport(int teacherId) async {
    final url = Uri.parse('$base/teacher-report/$teacherId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load report: ${response.body}');
    }
  }
}



