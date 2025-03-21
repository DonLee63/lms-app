enum LoginStatus { initial, loading, success, error }

enum RegisterStatus { initial, loading, success, error }

enum TabLoginPage { login, register }

enum UpdateStatus {
  initial, // Mặc định khi chưa có hành động gì
  updating, // Đang trong quá trình cập nhật
  success, // Cập nhật thành công
  failure, // Cập nhật thất bại
}
