import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/providers/teaching_content_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_upload_content_screen.dart';

class TeacherTeachingContentScreen extends ConsumerStatefulWidget {
  final int teacherId;
  final int phancongId;

  const TeacherTeachingContentScreen({
    super.key,
    required this.teacherId,
    required this.phancongId,
  });

  @override
  ConsumerState<TeacherTeachingContentScreen> createState() => _TeacherTeachingContentScreenState();
}

class _TeacherTeachingContentScreenState extends ConsumerState<TeacherTeachingContentScreen> {
  late Future<List<dynamic>> _teachingContentFuture;

  @override
  void initState() {
    super.initState();
    _teachingContentFuture = ref.read(teachingContentForTeacherProvider({
      'teacher_id': widget.teacherId,
      'phancong_id': widget.phancongId,
    }).future);
  }

  Future<void> _refresh() async {
    setState(() {
      _teachingContentFuture = ref.read(teachingContentForTeacherProvider({
        'teacher_id': widget.teacherId,
        'phancong_id': widget.phancongId,
      }).future);
    });
  }

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

  Future<void> _downloadFile(String? url, String fileName, BuildContext context) async {
    print('Bắt đầu tải file: $url');
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

    final hasPermission = await _requestStoragePermission(context);
    if (!hasPermission) {
      return;
    }

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
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          action: SnackBarAction(
            label: 'Mở file',
            onPressed: () async {
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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: const Text(
          'Tài liệu học tập',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refresh,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[850]!]
                : [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.blue[800],
          child: FutureBuilder<List<dynamic>>(
            future: _teachingContentFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: isDarkMode ? Colors.red[300] : Colors.red[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ScaleTransitionButton(
                        onPressed: _refresh,
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
                );
              }

              final teachingContents = snapshot.data ?? [];
              if (teachingContents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 48,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có tài liệu học tập nào',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: teachingContents.length,
                itemBuilder: (context, index) {
                  final content = teachingContents[index];
                  final fileName = content.fileUrl?.split('/').last ?? 'N/A';
                  final formattedDate = content.createdAt != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(content.createdAt!)
                      : 'N/A';

                  return FadeInUp(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 6.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDarkMode ? Colors.grey[800]! : Colors.blue[50]!,
                              isDarkMode ? Colors.grey[900]! : Colors.white,
                            ],
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue[100],
                            child: Icon(
                              Icons.description,
                              size: 28,
                              color: Colors.blue[800],
                            ),
                          ),
                          title: Text(
                            content.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.blue[900],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giảng viên: ${content.teacherName}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Ngày đăng: $formattedDate',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: content.downloadUrl != null
                              ? ScaleTransitionButton(
                                  onPressed: () async {
                                    await _downloadFile(content.downloadUrl, fileName, context);
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
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherUploadContentScreen(
                teacherId: widget.teacherId,
                phancongId: widget.phancongId,
              ),
            ),
          );
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.upload_file, color: Colors.white),
        tooltip: 'Tải lên tài liệu',
      ),
    );
  }
}

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