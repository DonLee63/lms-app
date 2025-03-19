import 'dart:convert';

class Quiz {
  final int id;
  final String title;
  final int hocphanId;
  final int totalPoints;
  final DateTime startTime;
  final DateTime endTime;
  final int time;
  final String type; // 'trac_nghiem' hoặc 'tu_luan'

  Quiz({
    required this.id,
    required this.title,
    required this.hocphanId,
    required this.totalPoints,
    required this.startTime,
    required this.endTime,
    required this.time,
    required this.type,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json['id'] as int,
        title: json['title'] as String,
        hocphanId: json['hocphan_id'] as int,
        totalPoints: json['total_points'] as int,
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: DateTime.parse(json['end_time'] as String),
        time: json['time'] as int,
        type: json['type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hocphan_id': hocphanId,
        'total_points': totalPoints,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'time': time,
        'type': type,
      };
}

class Assignment {
  final int? id;
  final int quizId;
  final String quizType;
  final int hocphanId; // Thay studentId bằng hocphanId
  final DateTime assignedAt;
  final DateTime dueDate;

  Assignment({
    this.id,
    required this.quizId,
    required this.quizType,
    required this.hocphanId,
    required this.assignedAt,
    required this.dueDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        id: json['id'] as int?,
        quizId: json['quiz_id'] as int,
        quizType: json['quiz_type'] as String,
        hocphanId: json['hocphan_id'] as int,
        assignedAt: DateTime.parse(json['assigned_at'] as String),
        dueDate: DateTime.parse(json['due_date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'quiz_id': quizId,
        'quiz_type': quizType,
        'due_date': dueDate.toIso8601String(),
      };
}

class StudentAssignment {
  final int assignmentId;
  final int quizId;
  final String quizType;
  final String title;
  final int totalPoints;
  final int time;
  final DateTime dueDate;

  StudentAssignment({
    required this.assignmentId,
    required this.quizId,
    required this.quizType,
    required this.title,
    required this.totalPoints,
    required this.time,
    required this.dueDate,
  });

  factory StudentAssignment.fromJson(Map<String, dynamic> json) => StudentAssignment(
        assignmentId: json['assignment_id'] as int,
        quizId: json['quiz_id'] as int,
        quizType: json['quiz_type'] as String,
        title: json['title'] as String,
        totalPoints: json['total_points'] as int,
        time: json['time'] as int,
        dueDate: DateTime.parse(json['due_date'] as String),
      );
}

class HocphanAssignments {
  final int hocphanId;
  final List<StudentAssignment> assignments;

  HocphanAssignments({
    required this.hocphanId,
    required this.assignments,
  });

  factory HocphanAssignments.fromJson(Map<String, dynamic> json) => HocphanAssignments(
        hocphanId: json['hocphan_id'] as int,
        assignments: (json['assignments'] as List)
            .map((item) => StudentAssignment.fromJson(item))
            .toList(),
      );
}