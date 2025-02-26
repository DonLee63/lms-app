class ChuyenNganh {
  final int id;
  final String title;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChuyenNganh({
    required this.id,
    required this.title,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ JSON sang model
  factory ChuyenNganh.fromJson(Map<String, dynamic> json) {
    return ChuyenNganh(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
