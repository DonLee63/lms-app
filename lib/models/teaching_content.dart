import '../constants/apilist.dart';

class TeachingContent {
  final int id;
  final int phancongId;
  final String title;
  final String slug;
  final String resources;
  final String? fileUrl; // Đường dẫn tương đối từ API
  final String teacherName;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeachingContent({
    required this.id,
    required this.phancongId,
    required this.title,
    required this.slug,
    required this.resources,
    this.fileUrl,
    required this.teacherName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter để tạo URL hoàn chỉnh
  String? get downloadUrl => fileUrl != null ? '$url_image$fileUrl' : null;

  factory TeachingContent.fromJson(Map<String, dynamic> json) {
    return TeachingContent(
      id: json['id'],
      phancongId: json['phancong_id'],
      title: json['title'],
      slug: json['slug'],
      resources: json['resources'],
      fileUrl: json['file_url'],
      teacherName: json['teacher_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phancong_id': phancongId,
      'title': title,
      'slug': slug,
      'resources': resources,
      'file_url': fileUrl,
      'teacher_name': teacherName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}