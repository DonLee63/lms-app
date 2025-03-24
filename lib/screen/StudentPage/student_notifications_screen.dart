import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/models/notification.dart';
import 'package:study_management_app/providers/notification_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

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
    if (url == null || url.isEmpty || !Uri.parse(url).isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File không tồn tại hoặc URL không hợp lệ')),
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
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải file...'),
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
          action: SnackBarAction(
            label: 'Mở file',
            onPressed: () async {
              // Mở file sau khi tải
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể mở file: ${result.message}')),
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
        SnackBar(content: Text('Lỗi khi tải file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe studentNotificationsProvider
    final notificationsAsync = ref.watch(studentNotificationsProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('Không có thông báo nào'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final fileName = notification.filePath.split('/').last; // Lấy tên file từ file_path
              return ListTile(
                title: Text(notification.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Giảng viên: ${notification.teacherName}'),
                    Text('Ngày gửi: ${notification.createdAt.toString()}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () async {
                    await downloadFile(notification.downloadUrl, fileName, context);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Làm mới provider để thử lại
                  ref.refresh(studentNotificationsProvider(studentId));
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}