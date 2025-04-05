import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/models/teaching_content.dart';
import 'package:study_management_app/providers/teaching_content_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:animate_do/animate_do.dart';

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
    _teachingContentFuture = ref.read(teachingContentRepositoryProvider).getTeachingContent(
      widget.studentId,
      widget.phancongId,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _teachingContentFuture = ref.read(teachingContentRepositoryProvider).getTeachingContent(
        widget.studentId,
        widget.phancongId,
      );
    });
  }

  Future<void> _downloadFile(String? url, String fileName, BuildContext context) async {
    // Giữ nguyên logic tải file
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refresh,
            tooltip: 'Làm mới',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[850]!]
                : [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.blue[700],
          child: FutureBuilder<List<TeachingContent>>(
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
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final contents = snapshot.data ?? [];
              if (contents.isEmpty) {
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
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  final content = contents[index];
                  final fileName = content.resources.split('/').last;

                  return FadeInUp(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 4.0,
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue[100],
                              child: Icon(
                                Icons.description,
                                size: 28,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    content.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Giảng viên: ${content.teacherName}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.download,
                                color: Colors.blue[700],
                                size: 28,
                              ),
                              onPressed: () async {
                                await _downloadFile(content.downloadUrl, fileName, context);
                              },
                              tooltip: 'Tải xuống',
                            ),
                          ],
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
    );
  }
}