import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/enum.dart';
import '../../constants/apilist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
    if (pickedFile != null) {
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

      await profileNotifier.saveProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin cá nhân'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: profileState.updateStatus == UpdateStatus.updating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (profileState.profile.photo.startsWith('http') 
                          ? NetworkImage(profileState.profile.photo) 
                          : NetworkImage(url_image + profileState.profile.photo)) as ImageProvider,
                          child: _avatarFile == null
                              ? const Icon(Icons.camera_alt, size: 50, color: Colors.white54)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Địa chỉ'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập địa chỉ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên đăng nhập';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Lưu thông tin'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue,
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
  }
}