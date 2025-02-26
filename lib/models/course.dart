class Course {
  final int phancongId;
  final String title;
  final String code;
  final int tinchi;
  final String classCourse;
  final int maxStudent;
  final String teacherName;
  final String loai;
  final int hocKyId;

  Course({
    required this.phancongId,
    required this.title,
    required this.code,
    required this.tinchi,
    required this.classCourse,
    required this.maxStudent,
    required this.teacherName,
    required this.loai,
    required this.hocKyId,
  });

  // Hàm chuyển đổi từ JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      phancongId: int.tryParse(json['phancong_id'].toString()) ?? 0,
      title: json['title']?.toString() ?? 'Chưa có tên',
      code: json['code']?.toString() ?? 'N/A',
      tinchi: int.tryParse(json['tinchi'].toString()) ?? 0,
      classCourse: json['class_course']?.toString() ?? 'N/A',
      maxStudent: int.tryParse(json['max_student'].toString()) ?? 0,
      teacherName: json['teacher_name']?.toString() ?? 'Không rõ',
      loai: json['loai']?.toString() ?? 'N/A',
      hocKyId: int.tryParse(json['hoc_ky_id'].toString()) ?? 0,
    );
  }

  // Hàm chuyển đổi ngược thành JSON (nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'phancong_id': phancongId,
      'title': title,
      'code': code,
      'tinchi': tinchi,
      'class_course': classCourse,
      'max_student': maxStudent,
      'teacher_name': teacherName,
      'loai': loai,
      'hoc_ky_id': hocKyId,
    };
  }
}
