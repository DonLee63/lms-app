import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/providers/teaching_content_provider.dart';

class TeacherUploadContentScreen extends ConsumerStatefulWidget {
  final int teacherId;
  final int phancongId;

  const TeacherUploadContentScreen({
    Key? key,
    required this.teacherId,
    required this.phancongId,
  }) : super(key: key);

  @override
  ConsumerState<TeacherUploadContentScreen> createState() => _TeacherUploadContentScreenState();
}

class _TeacherUploadContentScreenState extends ConsumerState<TeacherUploadContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  // Hàm chọn file từ thiết bị
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'], // Giới hạn loại file
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  // Hàm gửi nội dung giảng dạy
  Future<void> _submitContent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn file để tải lên')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ref.read(sendTeachingContentProvider({
        'teacher_id': widget.teacherId,
        'phancong_id': widget.phancongId,
        'title': _titleController.text,
        'file_path': _selectedFile!.path,
      }).future);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tải lên thành công: ${result['title']}')),
      );

      // Quay lại màn hình trước sau khi tải lên thành công
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải lên: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tải lên nội dung giảng dạy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trường nhập tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nút chọn file
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Chọn file'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Hiển thị tên file đã chọn
              if (_fileName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _fileName!,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Nút gửi
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitContent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text('Tải lên'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}