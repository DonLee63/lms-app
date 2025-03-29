class Enrollment {
  final int enrollmentId;
  final int phancongId;
  final int hocphanId;
  final String title;
  final int tinchi;
  final String courseCode;
  final String classCourse;
  final String teacherName;
  final String status;
  final String createdAt;

  Enrollment({
    required this.enrollmentId,
    required this.phancongId,
    required this.hocphanId,
    required this.title,
    required this.tinchi,
    required this.courseCode,
    required this.classCourse,
    required this.teacherName,
    required this.status,
    required this.createdAt,
  });

  // Chuyển từ JSON sang đối tượng Enrollment
  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      enrollmentId: json['enrollment_id'] ?? 0,
      phancongId: json['phancong_id'] ?? 0,
      hocphanId: json['hocphan_id'] ?? 0,
      title: json['title'] ?? 'N/A',
      tinchi: json['tinchi'] ?? 0,
      courseCode: json['course_code'] ?? 'N/A',
      classCourse: json['class_course'] ?? 'N/A',
      teacherName: json['teacher_name'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
      createdAt: json['created_at'] ?? 'N/A',
    );
  }

  // Chuyển từ đối tượng Enrollment sang JSON
  Map<String, dynamic> toJson() {
    return {
      'enrollment_id': enrollmentId,
      'phancong_id': phancongId,
      'hocphan_id': hocphanId,
      'title': title,
      'tinchi': tinchi,
      'course_code': courseCode,
      'class_course': classCourse,
      'teacher_name': teacherName,
      'status': status,
      'created_at': createdAt,
    };
  }
}
