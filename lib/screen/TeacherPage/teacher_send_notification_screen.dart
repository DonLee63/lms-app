import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import '../../providers/univerinfo_provider.dart';
import '../../providers/notification_provider.dart';

class TeacherSendNotificationScreen extends ConsumerStatefulWidget {
  final int teacherId;
  final int classId;

  const TeacherSendNotificationScreen({
    Key? key,
    required this.teacherId,
    required this.classId,
  }) : super(key: key);

  @override
  _TeacherSendNotificationScreenState createState() => _TeacherSendNotificationScreenState();
}

class _TeacherSendNotificationScreenState extends ConsumerState<TeacherSendNotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  PlatformFile? _selectedFile;
  int? _selectedClassId;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền tiêu đề và chọn lớp học'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tệp để gửi'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final file = await http.MultipartFile.fromPath(
        'file',
        _selectedFile!.path!,
        filename: _selectedFile!.name,
      );

      final params = {
        'teacherId': widget.teacherId,
        'classId': _selectedClassId!,
        'title': _titleController.text,
        'file': file,
      };

      await ref.read(sendNotificationProvider(params).future);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi thông báo thành công'), backgroundColor: Colors.green),
      );
      _titleController.clear();
      setState(() {
        _selectedFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(getClassesFutureProvider(widget.teacherId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Gửi thông báo',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: classesAsync.when(
          data: (classes) {
            if (classes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_,
                      size: 48,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có lớp học nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }
            _selectedClassId ??= widget.classId;
            return SingleChildScrollView(
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedClassId,
                          hint: const Text('Chọn lớp học'),
                          isExpanded: true,
                          items: classes.map((classModel) {
                            return DropdownMenuItem<int>(
                              value: classModel.id,
                              child: Text(classModel.className ?? 'Không có tên lớp'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClassId = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Lớp học',
                            prefixIcon: Icon(Icons.class_, color: isDarkMode ? Colors.blue[300] : Colors.blue[800]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Tiêu đề',
                            prefixIcon: Icon(Icons.title, color: isDarkMode ? Colors.blue[300] : Colors.blue[800]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Tải tài liệu lên'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 4.0,
                          ),
                        ),
                        if (_selectedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              children: [
                                Icon(Icons.insert_drive_file, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tệp đã chọn: ${_selectedFile!.name}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _sendNotification,
                                icon: const Icon(Icons.send),
                                label: const Text('Gửi thông báo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  minimumSize: const Size(double.infinity, 50),
                                  elevation: 4.0,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
          ),
          error: (error, stackTrace) => Center(
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
                  'Lỗi: $error',
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}