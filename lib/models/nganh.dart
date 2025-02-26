class Nganh {
  final int id;
  final String title;
  final String slug;
  final int donviId;
  final String code;
  final String content;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Nganh({
    required this.id,
    required this.title,
    required this.slug,
    required this.donviId,
    required this.code,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ JSON sang model
  factory Nganh.fromJson(Map<String, dynamic> json) {
    return Nganh(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      donviId: json['donvi_id'],
      code: json['code'],
      content: json['content'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Chuyển từ model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'donvi_id': donviId,
      'code': code,
      'content': content,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
