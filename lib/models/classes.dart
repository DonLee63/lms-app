class Classes {
  final int id;
  final String className;
  final int teacherId;
  final int nganhId;
  final int maxStudents;
  final DateTime createdAt;
  final DateTime updatedAt;

  Classes({
    required this.id,
    required this.className,
    required this.teacherId,
    required this.nganhId,
    required this.maxStudents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Classes.fromJson(Map<String, dynamic> json) {
    return Classes(
      id: json['id'],
      className: json['class_name'],
      teacherId: json['teacher_id'],
      nganhId: json['nganh_id'],
      maxStudents: json['max_students'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'teacher_id': teacherId,
      'nganh_id': nganhId,
      'max_students': maxStudents,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}