import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../router.dart';
// import 'edit_profile_screen.dart';
import '../../constants/enum.dart';
import '../../constants/apilist.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
              Navigator.of(context).pop();  // Quay lại trang trước
          },
        ),
      ),
      body: profileState.updateStatus == UpdateStatus.updating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profileState.profile.photo.isNotEmpty)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileState.profile.photo.startsWith('http') 
                          ? NetworkImage(profileState.profile.photo) 
                          : NetworkImage(url_image + profileState.profile.photo),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      profileState.profile.full_name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      profileState.profile.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 20),
                  _buildProfileInfoRow(context, 'Số điện thoại', profileState.profile.phone),
                  const SizedBox(height: 10),
                  _buildProfileInfoRow(context, 'Địa chỉ', profileState.profile.address),
                  const SizedBox(height: 10),
                  _buildProfileInfoRow(context, 'Tên đăng nhập', profileState.profile.username),
                  const SizedBox(height: 30),
                 Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.editprofile);
                      },
                      child: const Text('Chỉnh sửa thông tin cá nhân'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue, // Màu nền xanh dương
                        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Màu chữ
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: profileState.updateStatus == UpdateStatus.updating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profileState.profile.photo.isNotEmpty)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profileState.profile.photo),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      profileState.profile.full_name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      profileState.profile.email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  _buildProfileInfoRow('Số điện thoại', profileState.profile.phone),
                  const SizedBox(height: 10),
                  _buildProfileInfoRow('Địa chỉ', profileState.profile.address),
                  const SizedBox(height: 10),
                  _buildProfileInfoRow('Tên đăng nhập', profileState.profile.username),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(AppRoutes.editprofile);
                      },
                      child: const Text('Chỉnh sửa thông tin cá nhân'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
