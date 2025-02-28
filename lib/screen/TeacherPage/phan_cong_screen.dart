import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/univerinfo_provider.dart';
import '../../router.dart';

class PhanCongScreen extends ConsumerWidget {
  final int teacherId;

  const PhanCongScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phanCongAsync = ref.watch(phanCongProvider(teacherId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách phân công'),
      ),
      body: phanCongAsync.when(
        data: (phancongs) => ListView.builder(
          itemCount: phancongs.length,
          itemBuilder: (context, index) {
            final phancong = phancongs[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(phancong.hocphanTitle),
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
                  // Chuyển hướng đến CourseClassScreen và truyền dữ liệu
                   Navigator.of(context).pushNamed(AppRoutes.courseClass, arguments: {'teacherId': teacherId, 'phancongId': phancong.phancongId});
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}
