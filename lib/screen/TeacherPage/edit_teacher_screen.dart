import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/univerinfo_provider.dart';

class EditTeacherScreen extends ConsumerWidget {
  final int userId;

  const EditTeacherScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final donvisFuture = ref.watch(donvisFutureProvider);
    final chuyennganhsFuture = ref.watch(chuyenNganhFutureProvider);

    return FutureBuilder<int?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue))));
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: isDarkMode ? Colors.red[300] : Colors.red[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy người dùng',
                    style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        final userId = snapshot.data!;
        return _EditTeacherForm(userId: userId);
      },
    );
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}

class _EditTeacherForm extends ConsumerStatefulWidget {
  final int userId;

  const _EditTeacherForm({required this.userId});

  @override
  _EditTeacherFormState createState() => _EditTeacherFormState();
}

class _EditTeacherFormState extends ConsumerState<_EditTeacherForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _mgvController;
  late TextEditingController _hochamController;
  late TextEditingController _hocviController;
  late TextEditingController _loaiGiangvienController;
  int? selectedDonviId;
  int? selectedChuyenNganhId;

  @override
  void initState() {
    super.initState();
    _mgvController = TextEditingController();
    _hochamController = TextEditingController();
    _hocviController = TextEditingController();
    _loaiGiangvienController = TextEditingController();
    // Tải dữ liệu trong một Future riêng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeacherData();
    });
  }

  Future<void> _loadTeacherData() async {
    final teacher = await ref.read(teacherRepositoryProvider.notifier).showTeacher(widget.userId);
    if (teacher != null && mounted) {
      setState(() {
        _mgvController.text = teacher.mgv;
        _hochamController.text = teacher.hocHam ?? '';
        _hocviController.text = teacher.hocVi ?? '';
        _loaiGiangvienController.text = teacher.loaiGiangvien;
        selectedDonviId = teacher.maDonvi;
        selectedChuyenNganhId = teacher.chuyenNganh;
      });
    }
  }

  @override
  void dispose() {
    _mgvController.dispose();
    _hochamController.dispose();
    _hocviController.dispose();
    _loaiGiangvienController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final donvisFuture = ref.watch(donvisFutureProvider);
    final chuyennganhsFuture = ref.watch(chuyenNganhFutureProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Chỉnh sửa thông tin giảng viên',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              FadeInUp(
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
                        _buildTextField(
                          controller: _mgvController,
                          label: 'Mã giảng viên',
                          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập mã giảng viên' : null,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        donvisFuture.when(
                          data: (donvis) => _buildDropdown(
                            value: selectedDonviId,
                            items: donvis.map((donvi) => DropdownMenuItem<int>(value: donvi['id'], child: Text(donvi['title']))).toList(),
                            label: 'Chọn Đơn vị',
                            onChanged: (value) => setState(() => selectedDonviId = value),
                            validator: (value) => value == null ? 'Vui lòng chọn Đơn vị' : null,
                            isDarkMode: isDarkMode,
                          ),
                          loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue))),
                          error: (error, stack) => Text('Không tải được danh sách đơn vị', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                        ),
                        const SizedBox(height: 16),
                        chuyennganhsFuture.when(
                          data: (nganhs) => _buildDropdown(
                            value: selectedChuyenNganhId,
                            items: nganhs.map((nganh) => DropdownMenuItem<int>(value: nganh['id'], child: Text(nganh['title']))).toList(),
                            label: 'Chọn Ngành',
                            onChanged: (value) => setState(() => selectedChuyenNganhId = value),
                            validator: (value) => value == null ? 'Vui lòng chọn Ngành' : null,
                            isDarkMode: isDarkMode,
                          ),
                          loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue))),
                          error: (error, stack) => Text('Không tải được danh sách ngành', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _hochamController,
                          label: 'Học hàm',
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _hocviController,
                          label: 'Học vị',
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _loaiGiangvienController,
                          label: 'Loại giảng viên',
                          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập loại giảng viên' : null,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final mgv = _mgvController.text;
                      final hocham = _hochamController.text.isEmpty ? null : _hochamController.text;
                      final hocvi = _hocviController.text.isEmpty ? null : _hocviController.text;
                      final loaiGiangvien = _loaiGiangvienController.text;

                      try {
                        await ref.read(teacherRepositoryProvider.notifier).updateTeacher(
                              userId: widget.userId,
                              mgv: mgv,
                              donviId: selectedDonviId!,
                              chuyennganhId: selectedChuyenNganhId!,
                              hocHam: hocham ?? '',
                              hocVi: hocvi ?? '',
                              loaiGiangvien: loaiGiangvien,
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green[700]),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red[700]),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Lưu thông tin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    required bool isDarkMode,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required String label,
    required void Function(int?) onChanged,
    String? Function(int?)? validator,
    required bool isDarkMode,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
      validator: validator,
    );
  }
}