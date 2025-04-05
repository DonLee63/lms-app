import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../router.dart';
import '../../constants/enum.dart';
import '../../constants/apilist.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Thông tin cá nhân',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue[100],
                            backgroundImage: profileState.profile.photo.isNotEmpty
                                ? NetworkImage(
                                    profileState.profile.photo.startsWith('http')
                                        ? profileState.profile.photo
                                        : url_image + profileState.profile.photo,
                                  )
                                : null,
                            child: profileState.profile.photo.isEmpty
                                ? Icon(Icons.person, size: 70, color: Colors.blue[800])
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profileState.profile.full_name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email, size: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text(
                                profileState.profile.email,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
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
                            _buildProfileInfoRow(
                              context,
                              'Số điện thoại',
                              profileState.profile.phone.isNotEmpty ? profileState.profile.phone : 'Chưa cập nhật',
                              Icons.phone,
                              isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildProfileInfoRow(
                              context,
                              'Địa chỉ',
                              profileState.profile.address.isNotEmpty ? profileState.profile.address : 'Chưa cập nhật',
                              Icons.location_on,
                              isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildProfileInfoRow(
                              context,
                              'Tên đăng nhập',
                              profileState.profile.username,
                              Icons.person_outline,
                              isDarkMode,
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
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.editprofile);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Chỉnh sửa thông tin'),
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
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, String label, String value, IconData icon, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: isDarkMode ? Colors.grey[300] : Colors.blue[700],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}