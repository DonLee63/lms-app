class Tag {
  final int id;
  final String slug;
  final String title;
  final int hit;

  Tag({
    required this.id,
    required this.title,
    required this.slug,
    required this.hit,
  });

  // Tạo factory constructor để chuyển từ Map sang Tag
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      slug: json['slug'] as String,
      title: json['title'] as String,
      hit: json['hit'] ?? 0 as int,
    );
  }

  // Chuyển từ Tag sang Map (nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'hit': hit,
    };
  }
}
