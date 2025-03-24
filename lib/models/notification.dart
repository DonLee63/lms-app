import '../constants/apilist.dart';

class Notification {
  final int id;
  final int classId;
  final int teacherId;
  final String title;
  final String filePath;
  final String? fileUrl; // Đường dẫn tương đối từ API
  final String teacherName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notification({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.title,
    required this.filePath,
    this.fileUrl, // fileUrl có thể null nếu file không tồn tại
    required this.teacherName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter để tạo URL hoàn chỉnh bằng cách nối fileUrl với url_image
  String? get downloadUrl => fileUrl != null ? '$url_image$fileUrl' : null;

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      classId: json['class_id'],
      teacherId: json['teacher_id'],
      title: json['title'],
      filePath: json['file_path'],
      fileUrl: json['file_url'], // Lấy file_url từ API
      teacherName: json['teacher_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'teacher_id': teacherId,
      'title': title,
      'file_path': filePath,
      'file_url': fileUrl,
      'teacher_name': teacherName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}