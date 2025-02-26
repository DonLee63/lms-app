class Question {
  final int id;
  final String content;
  final int hocphanId;
  final Map<String, dynamic>? resources;
  final int loaiId;
  final int userId;

  Question({
    required this.id,
    required this.content,
    required this.hocphanId,
    this.resources,
    required this.loaiId,
    required this.userId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      content: json['content'],
      hocphanId: json['hocphan_id'],
      resources: json['resources'] != null ? Map<String, dynamic>.from(json['resources']) : null,
      loaiId: json['loai_id'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'hocphan_id': hocphanId,
      'resources': resources,
      'loai_id': loaiId,
      'user_id': userId,
    };
  }
}

class Answer {
  final int id;
  final int tracnghiemId;
  final String content;
  final String? resounceList;
  final bool isCorrect;

  Answer({
    required this.id,
    required this.tracnghiemId,
    required this.content,
    this.resounceList,
    required this.isCorrect,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      tracnghiemId: json['tracnghiem_id'],
      content: json['content'],
      resounceList: json['resounce_list'],
      isCorrect: json['is_correct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracnghiem_id': tracnghiemId,
      'content': content,
      'resounce_list': resounceList,
      'is_correct': isCorrect,
    };
  }
}

class Quiz {
  final int id;
  final String title;
  final int hocphanId;
  final String startTime;
  final String endTime;
  final int time;
  final String? tags;
  final int userId;
  final int totalPoints;
  final List<Map<String, dynamic>> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.hocphanId,
    required this.startTime,
    required this.endTime,
    required this.time,
    this.tags,
    required this.userId,
    required this.totalPoints,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      hocphanId: json['hocphan_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      time: json['time'],
      tags: json['tags'],
      userId: json['user_id'],
      totalPoints: json['total_points'],
      questions: List<Map<String, dynamic>>.from(json['questions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hocphan_id': hocphanId,
      'start_time': startTime,
      'end_time': endTime,
      'time': time,
      'tags': tags,
      'user_id': userId,
      'total_points': totalPoints,
      'questions': questions,
    };
  }
}
