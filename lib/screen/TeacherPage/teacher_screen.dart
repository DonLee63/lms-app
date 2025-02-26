import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/navigation/main_page.dart';
import 'package:study_management_app/screen/AuthPage/register_screen.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/univerinfo_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherScreen extends ConsumerStatefulWidget {
  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends ConsumerState<TeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mgvController = TextEditingController();
  final _hocHamController = TextEditingController();
  final _hocViController = TextEditingController();
  final _loaiGiangVienController = TextEditingController();
  int userId = 0;

  int? selectedDonViId;
  int? selectedChuyenNganhId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _mgvController.dispose();
    _hocHamController.dispose();
    _hocViController.dispose();
    _loaiGiangVienController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('userId');
    print('Current saved userId: $savedUserId'); // Debug print
    
    if (savedUserId == null || savedUserId <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found. Please register again.'),
            backgroundColor: Colors.red,
          ),
        );
        // Chuyển về màn đăng ký
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SignupPage()),
        );
      }
      return;
    }
    
    setState(() {
      userId = savedUserId;
    });
  }

  void _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        print('Current userId: $userId');  // Thêm dòng này
        
        if (userId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User ID không hợp lệ'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (selectedDonViId == null || 
            selectedChuyenNganhId == null || 
            _loaiGiangVienController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng chọn đầy đủ Đơn vị, Chuyên ngành và Loại giảng viên'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final teacherNotifier = ref.read(teacherRepositoryProvider.notifier);
        await teacherNotifier.createTeacher(
          mgv: _mgvController.text,
          maDonvi: selectedDonViId!,
          userId: userId,
          chuyenNganh: selectedChuyenNganhId!,
          hocHam: _hocHamController.text,
          hocVi: _hocViController.text,
          loaiGiangvien: _loaiGiangVienController.text,
        );

        // Hide loading
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo giảng viên thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
      }
    } catch (e) {
      // Hide loading if showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error in SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5), // Thời gian hiển thị lâu hơn
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chuyenNganhsFuture = ref.watch(chuyenNganhFutureProvider);
    final donvisFuture = ref.watch(donvisFutureProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Text(
                    "Create Teacher",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Fill in the details below",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _mgvController,
                      decoration: const InputDecoration(labelText: 'MGV'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter MGV';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _hocHamController,
                      decoration: const InputDecoration(labelText: 'Hoc Ham'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Hoc Ham';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _hocViController,
                      decoration: const InputDecoration(labelText: 'Hoc Vi'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Hoc Vi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _loaiGiangVienController,
                      decoration: const InputDecoration(labelText: 'Loai Giang Vien'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Loai Giang Vien';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    donvisFuture.when(
                      data: (donvis) {
                        return DropdownButtonFormField<int>(
                          value: selectedDonViId,
                          decoration: const InputDecoration(labelText: 'Select Donvi'),
                          items: donvis.map<DropdownMenuItem<int>>((donvi) {
                            return DropdownMenuItem<int>(
                              value: donvi['id'],
                              child: Text(donvi['title']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDonViId = value;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a Donvi' : null,
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Failed to load donvis'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    chuyenNganhsFuture.when(
                      data: (chuyenNganhs) {
                        return DropdownButtonFormField<int>(
                          value: selectedChuyenNganhId,
                          decoration: const InputDecoration(labelText: 'Select Chuyen Nganh'),
                          items: chuyenNganhs.map<DropdownMenuItem<int>>((chuyenNganh) {
                            return DropdownMenuItem<int>(
                              value: chuyenNganh['id'],
                              child: Text(chuyenNganh['title']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedChuyenNganhId = value;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a Chuyen Nganh' : null,
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Failed to load chuyen nganhs'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Create Teacher'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        backgroundColor: const Color.fromARGB(255, 50, 84, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}