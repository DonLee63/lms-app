import 'dart:convert';

class TuluanCauhoi {
  final int? id;
  final String content;
  final int hocphanId;
  final List<int>? resources;
  final int userId;

  TuluanCauhoi({
    this.id,
    required this.content,
    required this.hocphanId,
    this.resources,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'hocphan_id': hocphanId,
        'resources': resources,
        'user_id': userId,
      };

  factory TuluanCauhoi.fromJson(Map<String, dynamic> json) => TuluanCauhoi(
    id: json['id'] is int ? json['id'] : null, // Chỉ lấy nếu là int, иначе null
    content: json['content'] ?? '', // Thêm giá trị mặc định nếu null
    hocphanId: json['hocphan_id'] ?? 0, // Giá trị mặc định nếu null
    resources: json['resources'] != null ? List<int>.from(jsonDecode(json['resources'])) : null,
    userId: json['user_id'] ?? 0, // Giá trị mặc định nếu null
);
}

class BodeTuluan {
  final int? id;
  final String title;
  final int hocphanId;
  final String slug;
  final DateTime startTime;
  final DateTime endTime;
  final int time;
  final String? tags;
  final int totalPoints;
  final List<Map<String, dynamic>> questions;
  final int userId;

  BodeTuluan({
    this.id,
    required this.title,
    required this.hocphanId,
    required this.slug,
    required this.startTime,
    required this.endTime,
    required this.time,
    this.tags,
    required this.totalPoints,
    required this.questions,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'hocphan_id': hocphanId,
        'slug': slug,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'time': time,
        'tags': tags,
        'total_points': totalPoints,
        'questions': questions,
        'user_id': userId,
      };

  factory BodeTuluan.fromJson(Map<String, dynamic> json) => BodeTuluan(
        id: json['id'],
        title: json['title'],
        hocphanId: json['hocphan_id'],
        slug: json['slug'],
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        time: json['time'],
        tags: json['tags'],
        totalPoints: json['total_points'],
        questions: json['questions'] is String
            ? List<Map<String, dynamic>>.from(jsonDecode(json['questions']))
            : List<Map<String, dynamic>>.from(json['questions']),
        userId: json['user_id'],
      );
}