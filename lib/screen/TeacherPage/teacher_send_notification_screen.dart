import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
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
        const SnackBar(content: Text('Vui lòng điền tiêu đề và chọn lớp học')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tệp để gửi')),
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

      // Sử dụng sendNotificationProvider để gửi thông báo
      final params = {
        'teacherId': widget.teacherId,
        'classId': _selectedClassId!,
        'title': _titleController.text,
        'file': file,
      };

      await ref.read(sendNotificationProvider(params).future);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi thông báo thành công')),
      );
      _titleController.clear();
      setState(() {
        _selectedFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Gửi thông báo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: classesAsync.when(
          data: (classes) {
            if (classes.isEmpty) {
              return const Center(child: Text('Không có lớp học nào'));
            }
            _selectedClassId ??= widget.classId;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chọn lớp học
                  DropdownButton<int>(
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
                  ),
                  const SizedBox(height: 16),
                  // Tiêu đề
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Chọn tệp
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Tải tài liệu lên'),
                  ),
                  if (_selectedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Tệp đã chọn: ${_selectedFile!.name}'),
                    ),
                  const SizedBox(height: 16),
                  // Gửi thông báo
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _sendNotification,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Gửi thông báo'),
                        ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Lỗi: $error')),
        ),
      ),
    );
  }
}