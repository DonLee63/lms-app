class PhanCong {
  final int phancongId;
  final String hocphanTitle;
  final int tinchi;
  final String hocphanCode;
  final String classCourse;
  final String ngayPhanCong;
  final String teacherName;

  PhanCong({
    required this.phancongId,
    required this.hocphanTitle,
    required this.tinchi,
    required this.hocphanCode,
    required this.classCourse,
    required this.ngayPhanCong,
    required this.teacherName,
  });

  factory PhanCong.fromJson(Map<String, dynamic> json) {
    return PhanCong(
      phancongId: json['phancong_id'],
      hocphanTitle: json['hocphan_title'],
      tinchi: json['tinchi'],
      hocphanCode: json['hocphan_code'],
      classCourse: json['class_course'],
      ngayPhanCong: json['ngayphancong'],
      teacherName: json['teacher_name'],
    );
  }
}
