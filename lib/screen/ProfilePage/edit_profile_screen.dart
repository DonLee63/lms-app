import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/enum.dart';
import '../../constants/apilist.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    _fullNameController.text = profile.full_name;
    _addressController.text = profile.address;
    _usernameController.text = profile.username;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileNotifier = ref.read(profileProvider.notifier);
      profileNotifier.updatefull_name(_fullNameController.text);
      profileNotifier.updateAddress(_addressController.text);
      profileNotifier.updateUsername(_usernameController.text);

      if (_avatarFile != null) {
        await profileNotifier.uploadAndUpdatePhoto(_avatarFile!);
      }

      try {
        await profileNotifier.saveProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green[700]),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red[700]),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Chỉnh sửa thông tin cá nhân',
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
      body: profileState.updateStatus == UpdateStatus.updating
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.blue[100],
                                backgroundImage: _avatarFile != null
                                    ? FileImage(_avatarFile!)
                                    : (profileState.profile.photo.isNotEmpty
                                        ? NetworkImage(
                                            profileState.profile.photo.startsWith('http')
                                                ? profileState.profile.photo
                                                : url_image + profileState.profile.photo,
                                          )
                                        : null) as ImageProvider?,
                                child: _avatarFile == null && profileState.profile.photo.isEmpty
                                    ? Icon(Icons.person, size: 70, color: Colors.blue[800])
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[700],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
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
                                controller: _fullNameController,
                                label: 'Họ và tên',
                                icon: Icons.person,
                                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập họ và tên' : null,
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Địa chỉ',
                                icon: Icons.location_on,
                                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _usernameController,
                                label: 'Tên đăng nhập',
                                icon: Icons.account_circle,
                                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
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
    required IconData icon,
    String? Function(String?)? validator,
    required bool isDarkMode,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
        prefixIcon: Icon(icon, color: isDarkMode ? Colors.grey[300] : Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      validator: validator,
    );
  }
}