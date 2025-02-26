import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin sinh viên'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: _mssvController,
                decoration: const InputDecoration(
                  labelText: 'Mã sinh viên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã sinh viên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Dropdown cho Đơn vị
              donvisFuture.when(
                data: (donvis) {
                  if (!donvis.any((item) => item['id'] == selectedDonviId)) {
                    selectedDonviId = null; // Reset nếu không tìm thấy giá trị hợp lệ
                  }

                  return DropdownButtonFormField<int>(
                    value: selectedDonviId,
                    items: donvis
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
                    decoration: const InputDecoration(
                      labelText: 'Chọn Đơn vị',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => const Text('Lỗi khi tải dữ liệu Đơn vị'),
              ),
              const SizedBox(height: 10),

              // Dropdown cho Ngành
              nganhsFuture.when(
                data: (nganhs) {
                  if (!nganhs.any((item) => item['id'] == selectedNganhId)) {
                    selectedNganhId = null;
                  }

                  return DropdownButtonFormField<int>(
                    value: selectedNganhId,
                    items: nganhs
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
                    decoration: const InputDecoration(
                      labelText: 'Chọn Ngành',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => const Text('Lỗi khi tải dữ liệu Ngành'),
              ),
              const SizedBox(height: 10),

              // Dropdown cho Lớp
              classesFuture.when(
                data: (classes) {
                  if (!classes.any((item) => item['id'] == selectedClassId)) {
                    selectedClassId = null;
                  }

                  return DropdownButtonFormField<int>(
                    value: selectedClassId,
                    items: classes
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
                    decoration: const InputDecoration(
                      labelText: 'Chọn Lớp',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => const Text('Lỗi khi tải dữ liệu Lớp'),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _khoaController,
                decoration: const InputDecoration(
                  labelText: 'Khoá',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập khoá';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
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
                  style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.blue,
                              textStyle: const TextStyle(fontSize: 18),
                              foregroundColor: Theme.of(context).colorScheme.onPrimary, // Màu chữ
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                  child: const Text('Lưu thông tin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
