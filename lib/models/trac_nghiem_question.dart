import 'dart:convert';

class TracNghiemCauhoi {
  final int? id;
  final String content;
  final int hocphanId;
  final List<int>? resources;
  final int loaiId;
  final int userId;
  final List<TracNghiemDapan>? answers;

  TracNghiemCauhoi({
    this.id,
    required this.content,
    required this.hocphanId,
    this.resources,
    required this.loaiId,
    required this.userId,
    this.answers,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'hocphan_id': hocphanId,
        'resources': resources,
        'loai_id': loaiId,
        'user_id': userId,
      };

  factory TracNghiemCauhoi.fromJson(Map<String, dynamic> json) => TracNghiemCauhoi(
        id: json['id'],
        content: json['content'],
        hocphanId: json['hocphan_id'],
        resources: json['resources'] != null ? List<int>.from(jsonDecode(json['resources'])) : null,
        loaiId: json['loai_id'],
        userId: json['user_id'] ?? 0, // Giả định user_id luôn có từ API
        answers: json['answers'] != null
            ? (json['answers'] as List).map((item) => TracNghiemDapan.fromJson(item)).toList()
            : null,
      );
}

class TracNghiemDapan {
  final int? id;
  final int tracnghiemId;
  final String content;
  final List<int>? resounceList;
  final bool isCorrect;

  TracNghiemDapan({
    this.id,
    required this.tracnghiemId,
    required this.content,
    this.resounceList,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
        'tracnghiem_id': tracnghiemId,
        'content': content,
        'resounce_list': resounceList,
        'is_correct': isCorrect,
      };

  factory TracNghiemDapan.fromJson(Map<String, dynamic> json) => TracNghiemDapan(
        id: json['id'],
        tracnghiemId: json['tracnghiem_id'],
        content: json['content'],
        resounceList: json['resounce_list'] != null ? List<int>.from(jsonDecode(json['resounce_list'])) : null,
        isCorrect: json['is_correct'],
      );
}

class BodeTracNghiem {
  final int? id;
  final String title;
  final int hocphanId;
  final String slug;
  final DateTime startTime;
  final DateTime endTime;
  final int time;
  final String? tags;
  final int userId;
  final int totalPoints;
  final List<Map<String, dynamic>> questions;

  BodeTracNghiem({
    this.id,
    required this.title,
    required this.hocphanId,
    required this.slug,
    required this.startTime,
    required this.endTime,
    required this.time,
    this.tags,
    required this.userId,
    required this.totalPoints,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'hocphan_id': hocphanId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'time': time,
        'tags': tags,
        'total_points': totalPoints,
        'questions': questions,
        'user_id': userId,
      };

  factory BodeTracNghiem.fromJson(Map<String, dynamic> json) => BodeTracNghiem(
        id: json['id'],
        title: json['title'],
        hocphanId: json['hocphan_id'],
        slug: json['slug'],
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        time: json['time'],
        tags: json['tags'],
        userId: json['user_id'] ?? 0,
        totalPoints: json['total_points'],
        questions: List<Map<String, dynamic>>.from(jsonDecode(json['questions'])),
      );
}