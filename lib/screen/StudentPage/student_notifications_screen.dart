import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/models/notification.dart';
import 'package:study_management_app/providers/notification_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:animate_do/animate_do.dart'; // Thêm thư viện animate_do để tạo animation
import 'package:intl/intl.dart'; // Thêm thư viện intl để định dạng ngày tháng

class StudentNotificationsScreen extends ConsumerWidget {
  final int studentId;

  const StudentNotificationsScreen({Key? key, required this.studentId}) : super(key: key);

  // Hàm kiểm tra và yêu cầu quyền lưu trữ
  Future<bool> _requestStoragePermission(BuildContext context) async {
    // Trên Android 13 trở lên, nếu chỉ cần truy cập hình ảnh, sử dụng Permission.photos
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted) {
      return true;
    }

    // Nếu cần truy cập các loại tệp khác (PDF, Word, v.v.), thử Permission.storage (Android 10 trở xuống)
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    }

    // Nếu quyền bị từ chối vĩnh viễn, hiển thị thông báo và cung cấp tùy chọn mở cài đặt
    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quyền truy cập tệp bị từ chối. Vui lòng cấp quyền trong cài đặt.'),
          action: SnackBarAction(
            label: 'Cài đặt',
            onPressed: () {
              openAppSettings(); // Mở cài đặt ứng dụng để người dùng cấp quyền
            },
          ),
        ),
      );
      return false;
    }

    // Nếu quyền bị từ chối (nhưng không vĩnh viễn), hiển thị thông báo
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần quyền truy cập để tải file')),
      );
      return false;
    }

    return false;
  }

  // Hàm tải file về thiết bị
  Future<void> downloadFile(String? url, String fileName, BuildContext context) async {
    // Kiểm tra URL trước khi tải
     print('Bắt đầu tải file: $url'); // Log để debug
    if (url == null || url.isEmpty || !Uri.parse(url).isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('File không tồn tại hoặc URL không hợp lệ'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
      return;
    }

    // Kiểm tra và yêu cầu quyền trước khi tải
    final hasPermission = await _requestStoragePermission(context);
    if (!hasPermission) {
      return;
    }

    // Hiển thị dialog tiến trình tải
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.blue[800],
            ),
            const SizedBox(height: 16),
            Text(
              'Đang tải file: $fileName',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Tải file từ URL
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/pdf,image/*', // Đảm bảo server trả về đúng định dạng
          // Nếu server yêu cầu token, thêm header Authorization
          // 'Authorization': 'Bearer your_token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể tải file: ${response.statusCode}');
      }

      // Lấy thư mục Downloads trên thiết bị (thư mục công khai)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download'); // Thư mục Downloads
      } else {
        directory = await getApplicationDocumentsDirectory(); // Dùng thư mục Documents trên iOS
      }

      // Đảm bảo thư mục tồn tại
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Tạo đường dẫn file
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Lưu file
      await file.writeAsBytes(response.bodyBytes);

      // Kiểm tra kích thước file để đảm bảo file không rỗng
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File tải về rỗng');
      }

      // Đóng dialog tiến trình
      Navigator.pop(context);

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tải file về: $filePath'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          action: SnackBarAction(
            label: 'Mở file',
            onPressed: () async {
              // Mở file sau khi tải
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Không thể mở file: ${result.message}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      // Đóng dialog tiến trình nếu có lỗi
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe studentNotificationsProvider
    final notificationsAsync = ref.watch(studentNotificationsProvider(studentId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ Dark Mode

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Màu xanh đậm chuyên nghiệp
        elevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Màu chữ trắng để luôn dễ đọc
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.refresh(studentNotificationsProvider(studentId));
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'Không có thông báo nào',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final fileName = notification.filePath.split('/').last; // Lấy tên file từ file_path
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(notification.createdAt); // Định dạng ngày

              return FadeInUp(
                duration: Duration(milliseconds: 600 + (index * 100)),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  elevation: 6.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isDarkMode ? Colors.grey[800]! : Colors.blue[50]!, // Gradient điều chỉnh theo chế độ
                          isDarkMode ? Colors.grey[900]! : Colors.white,
                        ],
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blue[900], // Màu chữ điều chỉnh
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giảng viên: ${notification.teacherName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
                            ),
                          ),
                          Text(
                            'Ngày gửi: $formattedDate',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
                            ),
                          ),
                        ],
                      ),
                      trailing: ScaleTransitionButton(
                        onPressed: () async {
                          await downloadFile(notification.downloadUrl, fileName, context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue[600]!,
                                Colors.blue[800]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tải file',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
                ),
              ),
              const SizedBox(height: 16),
              ScaleTransitionButton(
                onPressed: () {
                  ref.refresh(studentNotificationsProvider(studentId));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[600]!,
                        Colors.blue[800]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget tùy chỉnh để thêm hiệu ứng scale khi nhấn
class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ScaleTransitionButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _ScaleTransitionButtonState createState() => _ScaleTransitionButtonState();
}

class _ScaleTransitionButtonState extends State<ScaleTransitionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}