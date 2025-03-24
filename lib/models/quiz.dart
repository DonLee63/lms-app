import 'dart:convert';

class Quiz {
  final int id;
  final String title;
  final int hocphanId;
  final int totalPoints;
  final DateTime startTime;
  final DateTime endTime;
  final int time;
  final String type;

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
  final int? assignmentId;
  final int? quizId;
  final String? quizType;
  final int? hocphanId;
  final String? title;
  final int? totalPoints;
  final int? time;
  final DateTime? assignedAt;
  // final DateTime? dueDate;

  Assignment({
    this.assignmentId,
    this.quizId,
    this.quizType,
    this.hocphanId,
    this.title,
    this.totalPoints,
    this.time,
    this.assignedAt,
    // this.dueDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        assignmentId: json['assignment_id'] as int?,
        quizId: json['quiz_id'] as int?,
        quizType: json['quiz_type'] as String?,
        hocphanId: json['hocphan_id'] as int?,
        title: json['title'] as String?,
        totalPoints: json['total_points'] as int?,
        time: json['time'] as int?,
        assignedAt: json['assigned_at'] != null ? DateTime.parse(json['assigned_at'] as String) : null,
        // dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'quiz_id': quizId,
        'quiz_type': quizType,
        'hocphan_id': hocphanId,
        'title': title,
        'total_points': totalPoints,
        'time': time,
        'assigned_at': assignedAt?.toIso8601String(),
        // 'due_date': dueDate?.toIso8601String(),
      };
}

class HocphanAssignments {
  final int hocphanId;
  final String hocphanName; // Thêm trường hocphanName
  final List<StudentAssignment> assignments;

  HocphanAssignments({
    required this.hocphanId,
    required this.hocphanName,
    required this.assignments,
  });

  factory HocphanAssignments.fromJson(Map<String, dynamic> json) => HocphanAssignments(
        hocphanId: json['hocphan_id'] as int,
        hocphanName: json['hocphan_name'] as String? ?? 'Không xác định', // Parse hocphan_name
        assignments: (json['assignments'] as List)
            .map((item) => StudentAssignment.fromJson(item))
            .toList(),
      );
}

class StudentAssignment {
  final int assignmentId;
  final int quizId;
  final String quizType;
  final String title;
  final int totalPoints;
  final int time;
  final DateTime? startTime;
  final DateTime? endTime;
  // final DateTime dueDate;

  StudentAssignment({
    required this.assignmentId,
    required this.quizId,
    required this.quizType,
    required this.title,
    required this.totalPoints,
    required this.time,
    this.startTime,
    this.endTime,
    // required this.dueDate,
  });

  factory StudentAssignment.fromJson(Map<String, dynamic> json) => StudentAssignment(
        assignmentId: json['assignment_id'] as int,
        quizId: json['quiz_id'] as int,
        quizType: json['quiz_type'] as String,
        title: json['title'] as String,
        totalPoints: json['total_points'] as int,
        time: json['time'] as int,
        startTime: json['start_time'] != null ? DateTime.parse(json['start_time'] as String) : null,
        endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
        // dueDate: DateTime.parse(json['due_date'] as String),
      );
}

class QuizQuestion {
  final int id;
  final String content;
  final List<QuizAnswer>? answers;

  QuizQuestion({required this.id, required this.content, this.answers});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      content: json['content'] as String,
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => QuizAnswer.fromJson(a)).toList()
          : null,
    );
  }
}

class QuizAnswer {
  final int id;
  final String content;
  final bool isCorrect;

  QuizAnswer({required this.id, required this.content, required this.isCorrect});

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      id: json['id'] as int,
      content: json['content'] as String,
      isCorrect: json['is_correct'] == 1,
    );
  }
}


class Submission {
  final int? submissionId; // Cho phép null
  final int? assignmentId; // Cho phép null
  final int? studentId; // Cho phép null
  final String studentName;
  final String? submittedAt;
  final dynamic score;
  final String? answers;
  final String quizType;

  Submission({
    required this.submissionId,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    this.submittedAt,
    required this.score,
    this.answers,
    required this.quizType,
  });

  factory Submission.fromJson(Map<String, dynamic> json, String quizType) {
    return Submission(
      submissionId: json['submission_id'] is String
          ? int.tryParse(json['submission_id'])
          : (json['submission_id'] as int?),
      assignmentId: json['assignment_id'] is String
          ? int.tryParse(json['assignment_id'])
          : (json['assignment_id'] as int?),
      studentId: json['student_id'] is String
          ? int.tryParse(json['student_id'])
          : (json['student_id'] as int?),
      studentName: json['student_name'] as String? ?? 'Không xác định', // Xử lý null cho studentName
      submittedAt: json['submitted_at'] as String?,
      score: json['score'] is String ? null : json['score']?.toDouble(),
      answers: json['answers'] as String?,
      quizType: quizType,
    );
  }
}