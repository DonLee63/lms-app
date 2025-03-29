import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/univerinfo_provider.dart';
import 'enter_scores_screen.dart'; // Import màn hình EnterScoresScreen
import 'teacher_report_screen.dart'; // Import màn hình TeacherReportScreen

class TeacherHocPhanScreen extends ConsumerWidget {
  final int teacherId;

  const TeacherHocPhanScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giả sử bạn đã có provider để lấy danh sách học phần của giảng viên
    final hocPhanAsync = ref.watch(phanCongProvider(teacherId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách học phần'),
        backgroundColor: Colors.blue,
      ),
      body: hocPhanAsync.when(
        data: (phancongs) => ListView.builder(
          itemCount: phancongs.length,
          itemBuilder: (context, index) {
            final phancong = phancongs[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 2,
              child: ListTile(
                title: Text(
                  phancong.hocphanTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tín chỉ: ${phancong.tinchi}'),
                    Text('Lớp: ${phancong.classCourse}'),
                    Text('Ngày phân công: ${phancong.ngayPhanCong}'),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Chuyển hướng đến màn hình nhập điểm, sử dụng Navigator.push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnterScoresScreen(
                        hocphanId: phancong.hocphanId,
                        teacherId: teacherId,
                        phancongId: phancong.phancongId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
      // Thêm FloatingActionButton để điều hướng đến TeacherReportScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển hướng đến TeacherReportScreen, sử dụng Navigator.push
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherReportScreen(
                teacherId: teacherId,
              ),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.analytics), // Icon biểu thị thống kê và báo cáo
        tooltip: 'Thống kê và báo cáo',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Đặt ở góc dưới bên phải
    );
  }
}