import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/student_provider.dart';
import '../../providers/univerinfo_provider.dart';

class EditStudentScreen extends ConsumerStatefulWidget {
  const EditStudentScreen({super.key, required this.userId});

  final int userId;

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends ConsumerState<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _mssvController;
  late TextEditingController _khoaController;

  int? selectedDonviId;
  int? selectedNganhId;
  int? selectedClassId;

  @override
  void initState() {
    super.initState();
    _mssvController = TextEditingController();
    _khoaController = TextEditingController();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    Future.delayed(Duration.zero, () async {
      final student = await ref.read(studentRepositoryProvider.notifier).showStudent(widget.userId);
      if (student != null) {
        setState(() {
          _mssvController.text = student.mssv;
          _khoaController.text = student.khoa;
          selectedDonviId = student.donviId;
          selectedNganhId = student.nganhId;
          selectedClassId = student.classId;
        });
      }
    });
  }

  @override
  void dispose() {
    _mssvController.dispose();
    _khoaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donvisFuture = ref.watch(donvisFutureProvider);
    final nganhsFuture = selectedDonviId != null
        ? ref.watch(nganhsFutureProvider(selectedDonviId!))
        : const AsyncValue.data([]);
    final classesFuture = selectedNganhId != null
        ? ref.watch(classesFutureProvider(selectedNganhId!))
        : const AsyncValue.data([]);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Card(
            elevation: 6.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _mssvController,
                      label: 'Mã sinh viên',
                      icon: Icons.badge,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Vui lòng nhập mã sinh viên' : null,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      future: donvisFuture,
                      value: selectedDonviId,
                      label: 'Đơn vị',
                      icon: Icons.account_balance,
                      items: (data) => data
                          .map((donvi) => DropdownMenuItem<int>(
                                value: donvi['id'],
                                child: Text(donvi['title']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDonviId = value;
                          selectedNganhId = null;
                          selectedClassId = null;
                        });
                      },
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      future: nganhsFuture,
                      value: selectedNganhId,
                      label: 'Ngành',
                      icon: Icons.school,
                      items: (data) => data
                          .map((nganh) => DropdownMenuItem<int>(
                                value: nganh['id'],
                                child: Text(nganh['title']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedNganhId = value;
                          selectedClassId = null;
                        });
                      },
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      future: classesFuture,
                      value: selectedClassId,
                      label: 'Lớp',
                      icon: Icons.class_,
                      items: (data) => data
                          .map((classItem) => DropdownMenuItem<int>(
                                value: classItem['id'],
                                child: Text(classItem['class_name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClassId = value;
                        });
                      },
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _khoaController,
                      label: 'Khóa',
                      icon: Icons.calendar_today,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Vui lòng nhập khóa' : null,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (selectedDonviId == null || selectedNganhId == null || selectedClassId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng chọn đầy đủ Đơn vị, Ngành và Lớp'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final mssv = _mssvController.text;
                          final khoa = _khoaController.text;

                          await ref.read(studentRepositoryProvider.notifier).updateStudent(
                                userId: widget.userId,
                                mssv: mssv,
                                donviId: selectedDonviId!,
                                nganhId: selectedNganhId!,
                                classId: selectedClassId!,
                                khoa: khoa,
                              );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cập nhật thông tin thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu thông tin'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4.0,
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isDarkMode,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDarkMode ? Colors.blue[300] : Colors.blue[800]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required AsyncValue<List<dynamic>> future,
    required int? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<int>> Function(List<dynamic>) items,
    required void Function(int?) onChanged,
    required bool isDarkMode,
  }) {
    return future.when(
      data: (data) {
        if (value != null && !data.any((item) => item['id'] == value)) {
          value = null;
        }
        return DropdownButtonFormField<int>(
          value: value,
          items: items(data),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: isDarkMode ? Colors.blue[300] : Colors.blue[800]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Lỗi khi tải dữ liệu $label', style: const TextStyle(color: Colors.red)),
    );
  }
}