import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/models/teaching_content.dart';
import 'package:study_management_app/providers/teaching_content_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class StudentTeachingContentScreen extends ConsumerStatefulWidget {
  final int studentId;
  final int phancongId;
  final String courseTitle;

  const StudentTeachingContentScreen({
    Key? key,
    required this.studentId,
    required this.phancongId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  ConsumerState<StudentTeachingContentScreen> createState() => _StudentTeachingContentScreenState();
}

class _StudentTeachingContentScreenState extends ConsumerState<StudentTeachingContentScreen> {
  late Future<List<TeachingContent>> _teachingContentFuture;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Future để gọi API một lần khi màn hình được tạo
    _teachingContentFuture = ref.read(teachingContentRepositoryProvider).getTeachingContent(
      widget.studentId,
      widget.phancongId,
    );
  }

  // Hàm làm mới dữ liệu
  Future<void> _refresh() async {
    setState(() {
      _teachingContentFuture = ref.read(teachingContentRepositoryProvider).getTeachingContent(
        widget.studentId,
        widget.phancongId,
      );
    });
  }

  // Hàm yêu cầu quyền lưu trữ
  Future<bool> _requestStoragePermission(BuildContext context) async {
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted) {
      return true;
    }

    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quyền truy cập tệp bị từ chối. Vui lòng cấp quyền trong cài đặt.'),
          action: SnackBarAction(
            label: 'Cài đặt',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return false;
    }

    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần quyền truy cập để tải file')),
      );
      return false;
    }

    return false;
  }

  // Hàm tải file
  Future<void> _downloadFile(String? url, String fileName, BuildContext context) async {
    if (url == null || url.isEmpty || !Uri.parse(url).isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File không tồn tại hoặc URL không hợp lệ')),
      );
      return;
    }

    final hasPermission = await _requestStoragePermission(context);
    if (!hasPermission) {
      return;
    }

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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/pdf,image/*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể tải file: ${response.statusCode}');
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File tải về rỗng');
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tải file về: $filePath'),
          action: SnackBarAction(
            label: 'Mở file',
            onPressed: () async {
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Tài liệu học tập - ${widget.courseTitle}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<TeachingContent>>(
          future: _teachingContentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final contents = snapshot.data ?? [];
            if (contents.isEmpty) {
              return const Center(child: Text('Không có tài liệu học tập nào'));
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final content = contents[index];
                final fileName = content.resources.split('/').last;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: ListTile(
                    title: Text(
                      content.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giảng viên: ${content.teacherName}'),
                        Text('Ngày đăng: ${content.createdAt.toString()}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () async {
                        await _downloadFile(content.downloadUrl, fileName, context);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}