class Profile {
  final String email;
  final String full_name;
  final String phone;
  final String address;
  final String photo;
  final String username;
  final int id;

  const Profile({
    required this.email,
    required this.full_name,
    required this.phone,
    required this.address,
    required this.photo,
    required this.username,
    required this.id,
  });

  // Tạo phương thức từ JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      email: json['email'],
      full_name: json['full_name'],
      phone: json['phone'],
      address: json['address'],
      photo: json['avatar_url'],
      username: json['username'],
      id: json['id'],
    );
  }

  // Chuyển đổi Profile thành JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': full_name,
      'phone': phone,
      'address': address,
      'avatar_url': photo,
      'username': username,
      'id': id,
    };
  }

  Profile copyWith({
    String? email,
    String? full_name,
    String? phone,
    String? address,
    String? photo,
    String? username,
    int? id,
  }) {
    return Profile(
      email: email ?? this.email,
      full_name: full_name ?? this.full_name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      username: username ?? this.username,
      id: id ?? this.id,
    );
  }
}
