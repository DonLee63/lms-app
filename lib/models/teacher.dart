class Teacher {
  final int id;
  final String mgv; // Mã giảng viên
  final int maDonvi; // Mã đơn vị
  final int userId; // ID của người dùng
  final int chuyenNganh; // Chuyên ngành
  final String? hocHam; // Học hàm (nullable)
  final String? hocVi; // Học vị (nullable)
  final String loaiGiangvien; // Loại giảng viên 

  Teacher({
    required this.id,
    required this.mgv,
    required this.maDonvi,
    required this.userId,
    required this.chuyenNganh,
    this.hocHam,
    this.hocVi,
    required this.loaiGiangvien,
  });

  // Tạo Teacher từ JSON
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      mgv: json['mgv'],
      maDonvi: json['ma_donvi'],
      userId: json['user_id'],
      chuyenNganh: json['chuyen_nganh'],
      hocHam: json['hoc_ham'],
      hocVi: json['hoc_vi'],
      loaiGiangvien: json['loai_giangvien'],
    );
  }

  // Chuyển đổi Teacher thành JSON (nếu cần gửi đi)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mgv': mgv,
      'ma_donvi': maDonvi,
      'user_id': userId,
      'chuyen_nganh': chuyenNganh,
      'hoc_ham': hocHam,
      'hoc_vi': hocVi,
      'loai_giangvien': loaiGiangvien,
    };
  }
}
