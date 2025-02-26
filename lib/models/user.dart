class User {
  final int id;
  final String code;
  final int global_id;
  final String full_name;
  final String username;
  final String email;
  final String password;
  final String email_verified_at;
  final String photo;
  final String phone;
  final String address;
  final String description;
  final int ship_id;
  final int ugroup_id;
  final String role; // Role cần thiết: student/teacher
  final int budget;
  final int totalpoint;
  final int totalrevenue;
  final String taxcode;
  final String taxname;
  final String taxaddress;
  final String status;
  final String notification_count;
  final String birthday;
  final String gender;

  User({
    this.id = 0,
    this.username = '',
    required this.email,
    required this.password,
    this.ugroup_id = 0,
    required this.role, // Role cần thiết
    required this.full_name,
    this.status = 'active',
    this.phone= '',
    this.address = '',
    this.code = '',
    this.global_id = 0,
    this.description = '',
    this.ship_id = 0,
    this.email_verified_at = '',
    this.photo = '',
    this.budget = 0,
    this.totalpoint = 0,
    this.totalrevenue = 0,
    this.taxcode = '',
    this.taxname = '',
    this.taxaddress = '',
    this.notification_count = '0',
    this.birthday = '',
    this.gender = 'female',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'ugroup_id': ugroup_id,
      'role': role, // Đảm bảo role được gửi
      'full_name': full_name,
      'status': status,
      'phone': phone,
      'address': address,
      'code': code,
      'global_id': global_id,
      'description': description,
      'ship_id': ship_id,
      'email_verified_at': email_verified_at,
      'photo': photo,
      'budget': budget,
      'totalpoint': totalpoint,
      'totalrevenue': totalrevenue,
      'taxcode': taxcode,
      'taxname': taxname,
      'taxaddress': taxaddress,
      'notification_count': notification_count,
      'birthday': birthday,
      'gender': gender,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      ugroup_id: json['ugroup_id'] ?? 0,
      role: json['role'] ?? 'customer', // Gán mặc định nếu không có
      full_name: json['full_name'] ?? '',
      status: json['status'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      code: json['code'] ?? '',
      global_id: json['global_id'] ?? 0,
      description: json['description'] ?? '',
      ship_id: json['ship_id'] ?? 0,
      email_verified_at: json['email_verified_at'] ?? '',
      photo: json['photo'] ?? '',
      budget: json['budget'] ?? 0,
      totalpoint: json['totalpoint'] ?? 0,
      totalrevenue: json['totalrevenue'] ?? 0,
      taxcode: json['taxcode'] ?? '',
      taxname: json['taxname'] ?? '',
      taxaddress: json['taxaddress'] ?? '',
      birthday: json['birthday'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
}
