class   Student {
  final int id;
  final String mssv;
  final int donviId;
  final int nganhId;
  final int classId;
  final String khoa;
  final int userId;

  Student({
    required this.id,
    required this.mssv,
    required this.donviId,
    required this.nganhId,
    required this.classId,
    required this.khoa,
    required this.userId,
  });

  // Tạo Student từ JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      mssv: json['mssv']?? '',
      donviId: json['donvi_id'] ?? 0,
      nganhId: json['nganh_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      khoa: json['khoa']?? '',
      userId: json['user_id'],
    );
  }

  // Convert Student thành JSON (nếu cần gửi đi)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mssv': mssv,
      'donvi_id': donviId,
      'nganh_id': nganhId,
      'class_id': classId,
      'khoa': khoa,
      'user_id': userId,
    };
  }
}

class StudentModel {
  final int studentId;
  final String mssv;
  final String studentName;
  final String className;
  final String description;
  final String khoa;
  final String status;

  StudentModel({
    required this.studentId,
    required this.mssv,
    required this.studentName,
    required this.className,
    required this.description,
    required this.khoa,
    required this.status,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['student_id'] ?? 0,  // Nếu null, gán giá trị mặc định là 0
      mssv: json['mssv'] ?? '',            // Nếu null, gán chuỗi rỗng
      studentName: json['student_name'] ?? '',
      className: json['class_name'] ?? '',
      description: json['description'] ?? '',
      khoa: json['khoa'] ?? '',
      status: json['status'] ?? '',
    );
  }
}


class StudentCourse {
  final int studentId;
  final String studentName;
  final String mssv;
  final String courseTitle;
  final String courseCode;
  final int credits;
  final String classCourse;
  final String enrollmentStatus;
  final DateTime enrollmentDate;

  StudentCourse({
    required this.studentId,
    required this.studentName,
    required this.mssv,
    required this.courseTitle,
    required this.courseCode,
    required this.credits,
    required this.classCourse,
    required this.enrollmentStatus,
    required this.enrollmentDate,
  });

  factory StudentCourse.fromJson(Map<String, dynamic> json) {
    return StudentCourse(
      studentId: json['student_id'],
      studentName: json['student_name'],
      mssv: json['mssv'],
      courseTitle: json['course_title'],
      courseCode: json['course_code'],
      credits: json['credits'],
      classCourse: json['class_course'],
      enrollmentStatus: json['enrollment_status'],
      enrollmentDate: DateTime.parse(json['enrollment_date']),
    );
  }
}

