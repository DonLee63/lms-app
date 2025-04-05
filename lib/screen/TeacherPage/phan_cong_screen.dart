import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/univerinfo_provider.dart';
import '../../router.dart';

class PhanCongScreen extends ConsumerWidget {
  final int teacherId;

  const PhanCongScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phanCongAsync = ref.watch(phanCongProvider(teacherId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Danh sách phân công',
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
      body: phanCongAsync.when(
        data: (phancongs) {
          if (phancongs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 48,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có phân công nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: phancongs.length,
            itemBuilder: (context, index) {
              final phancong = phancongs[index];
              return FadeInUp(
                duration: Duration(milliseconds: 500 + (index * 100)),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 6.0,
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      phancong.hocphanTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[900],
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.credit_card, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                'Tín chỉ: ${phancong.tinchi}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.class_, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                'Lớp: ${phancong.classCourse}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                'Ngày phân công: ${phancong.ngayPhanCong}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.courseClass,
                        arguments: {'teacherId': teacherId, 'phancongId': phancong.phancongId},
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: isDarkMode ? Colors.red[300] : Colors.red[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi: $error',
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}