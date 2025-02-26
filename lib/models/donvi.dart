class DonVi {
  final int id;
  final String title;
  final String slug;
  final int? parentId;
  final int? childrenId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DonVi({
    required this.id,
    required this.title,
    required this.slug,
    this.parentId,
    this.childrenId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ JSON sang model
  factory DonVi.fromJson(Map<String, dynamic> json) {
    return DonVi(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      parentId: json['parent_id'] != null ? json['parent_id'] : null,
      childrenId: json['children_id'] != null ? json['children_id'] : null,
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
      'parent_id': parentId,
      'children_id': childrenId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
