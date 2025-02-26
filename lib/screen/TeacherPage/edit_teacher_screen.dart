import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/univerinfo_provider.dart'; // Import provider của Đơn vị và Ngành

class EditTeacherScreen extends ConsumerStatefulWidget {
  const EditTeacherScreen({Key? key, required this.userId}) : super(key: key);

  final int userId;

  @override
  _EditTeacherScreenState createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends ConsumerState<EditTeacherScreen> {
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
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    Future.delayed(Duration.zero, () async {
      final teacher = await ref.read(teacherRepositoryProvider.notifier).showTeacher(widget.userId);
      if (teacher != null) {
        setState(() {
          _mgvController.text = teacher.mgv;
          _hochamController.text = teacher.hocHam ?? '';
          _hocviController.text = teacher.hocVi ?? '';
          _loaiGiangvienController.text = teacher.loaiGiangvien;
          selectedDonviId = teacher.maDonvi;
          selectedChuyenNganhId = teacher.chuyenNganh;
        });
      }
    });
  }

  @override
  void dispose() {
    _mgvController.dispose();
    _hochamController.dispose();
    _hocviController.dispose();
    _loaiGiangvienController.dispose();
    super.dispose();
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId'); // Lấy userId từ SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    final donvisFuture = ref.watch(donvisFutureProvider);
    final chuyennganhsFuture = ref.watch(chuyenNganhFutureProvider);

    return FutureBuilder<int?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('User not found')),
          );
        }

        final userId = snapshot.data;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Chỉnh sửa thông tin giảng viên'),
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
                    controller: _mgvController,
                    decoration: const InputDecoration(
                      labelText: 'Mã giảng viên',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mã giảng viên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Dropdown cho Đơn vị
                  donvisFuture.when(
                    data: (donvis) {
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
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Chọn Đơn vị',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn Đơn vị';
                          }
                          return null;
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text('Failed to load Donvi data'),
                  ),
                  const SizedBox(height: 10),
                  // Dropdown cho Ngành
                  chuyennganhsFuture.when(
                    data: (nganhs) {
                      return DropdownButtonFormField<int>(
                        value: selectedChuyenNganhId,
                        items: nganhs
                            .map((nganh) => DropdownMenuItem<int>(
                                  value: nganh['id'],
                                  child: Text(nganh['title']),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedChuyenNganhId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Chọn Ngành',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn Ngành';
                          }
                          return null;
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text('Failed to load Nganh data'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _hochamController,
                    decoration: const InputDecoration(
                      labelText: 'Học hàm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _hocviController,
                    decoration: const InputDecoration(
                      labelText: 'Học vị',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _loaiGiangvienController,
                    decoration: const InputDecoration(
                      labelText: 'Loại giảng viên',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập loại giảng viên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final mgv = _mgvController.text;
                          final hocham = _hochamController.text;
                          final hocvi = _hocviController.text;
                          final loaiGiangvien = _loaiGiangvienController.text;

                          // Gọi hàm updateTeacher
                          await ref.read(teacherRepositoryProvider.notifier).updateTeacher(
                            userId: userId!,
                            mgv: mgv,
                            donviId: selectedDonviId!,
                            chuyennganhId: selectedChuyenNganhId!,
                            hocHam: hocham,
                            hocVi: hocvi,
                            loaiGiangvien: loaiGiangvien,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cập nhật thông tin thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context); // Trở về màn hình trước
                        }
                      },
                      child: const Text('Lưu thông tin'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 18),
                        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Màu chữ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}