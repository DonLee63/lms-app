import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/navigation/main_page.dart';
import 'package:study_management_app/screen/AuthPage/register_screen.dart';
import '../../providers/student_provider.dart';
import '../../providers/univerinfo_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentScreen extends ConsumerStatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends ConsumerState<StudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mssvController = TextEditingController();
  final _khoaController = TextEditingController();
  int userId = 0;

  int? selectedDonViId;
  int? selectedNganhId;
  int? selectedClassId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _mssvController.dispose();
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
            selectedNganhId == null ||
            selectedClassId == null ||
            _khoaController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng chọn đầy đủ Đơn vị, Ngành và Lớp'),
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

        final studentNotifier = ref.read(studentRepositoryProvider.notifier);
        await studentNotifier.createStudent(
          mssv: _mssvController.text,
          donviId: selectedDonViId!,
          nganhId: selectedNganhId!,
          classId: selectedClassId!,
          khoa: _khoaController.text,
          userId: userId,
        );

        // Hide loading
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo sinh viên thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainPage()),
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
    final donvisFuture = ref.watch(donvisFutureProvider);
    final nganhsFuture = selectedDonViId != null
        ? ref.watch(nganhsFutureProvider(selectedDonViId!))
        : const AsyncValue.data([]);
    final classesFuture = selectedNganhId != null
        ? ref.watch(classesFutureProvider(selectedNganhId!))
        : const AsyncValue.data([]);

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
                    "Create Student",
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
                      controller: _mssvController,
                      decoration: const InputDecoration(labelText: 'MSSV'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter MSSV';
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
                              selectedNganhId = null; // Reset ngành khi đơn vị thay đổi
                              selectedClassId = null; // Reset lớp khi đơn vị thay đổi
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
                    nganhsFuture.when(
                      data: (nganhs) {
                        return DropdownButtonFormField<int>(
                          value: selectedNganhId,
                          decoration: const InputDecoration(labelText: 'Select Nganh'),
                          items: nganhs.map<DropdownMenuItem<int>>((nganh) {
                            return DropdownMenuItem<int>(
                              value: nganh['id'],
                              child: Text(nganh['title']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedNganhId = value;
                              selectedClassId = null; // Reset lớp khi ngành thay đổi
                            });
                          },
                          validator: (value) => value == null ? 'Please select a Nganh' : null,
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Failed to load nganhs'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    classesFuture.when(
                      data: (classes) {
                        return DropdownButtonFormField<int>(
                          value: selectedClassId,
                          decoration: const InputDecoration(labelText: 'Select Class'),
                          items: classes.map<DropdownMenuItem<int>>((classItem) {
                            return DropdownMenuItem<int>(
                              value: classItem['id'],
                              child: Text(classItem['class_name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClassId = value;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a Class' : null,
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Failed to load classes'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _khoaController,
                      decoration: const InputDecoration(labelText: 'Niên khoá'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter niên khoá';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Create Student'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        backgroundColor: const Color.fromARGB(255, 50, 84, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        foregroundColor: Colors.white, // Thiết lập màu chữ
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