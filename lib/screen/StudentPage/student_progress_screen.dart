// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/course_provider.dart';

// class StudentProgressScreen extends ConsumerWidget {
//   final int studentId;

//   const StudentProgressScreen({super.key, required this.studentId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final progressAsync = ref.watch(studentProgressProvider(studentId));

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text('Theo dõi tiến độ học tập'),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               ref.invalidate(studentProgressProvider(studentId));
//             },
//           ),
//         ],
//       ),
//       body: progressAsync.when(
//         data: (progress) {
//           final progressData = progress['courses'] as List<dynamic>;
//           final totalCreditsCompleted = (progress['total_credits_completed'] as num).toDouble();
//           final totalCredits = (progress['total_credits'] as num).toDouble();
//           final gpa = (progress['gpa'] as num).toDouble();
//           final progressPercentage = (progress['progress_percentage'] as num).toDouble();
//           final requiredCredits = (progress['required_credits'] as num).toDouble();

//           // Phân loại học phần
//           final completedCourses = progressData.where((course) => course['is_completed'] == true).toList();
//           final ongoingCourses = progressData.where((course) => course['is_completed'] != true).toList();

//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Thông tin tổng quan
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Tổng quan',
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Tín chỉ hoàn thành:', style: TextStyle(fontSize: 16)),
//                               Text(
//                                 '${totalCreditsCompleted.toStringAsFixed(1)} / $requiredCredits',
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Điểm trung bình (GPA):', style: TextStyle(fontSize: 16)),
//                               Text(
//                                 gpa.toStringAsFixed(2),
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Tiến độ:', style: TextStyle(fontSize: 16)),
//                               Text(
//                                 '${progressPercentage.toStringAsFixed(1)}%',
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           LinearProgressIndicator(
//                             value: progressPercentage / 100,
//                             backgroundColor: Colors.grey[300],
//                             color: Colors.blue,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Học phần đã hoàn thành
//                   const Text(
//                     'Học phần đã hoàn thành',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   if (completedCourses.isEmpty)
//                     const Text('Chưa hoàn thành học phần nào.'),
//                   ...completedCourses.map((course) => Card(
//                         margin: const EdgeInsets.symmetric(vertical: 4.0),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                         child: ListTile(
//                           title: Text(
//                             course['title'],
//                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Tín chỉ: ${course['so_tin_chi']}'),
//                               Text('Điểm hệ số 4: ${course['diem_he_so_4']?.toStringAsFixed(1) ?? 'Chưa có'}'),
//                               Text('Điểm chữ: ${course['diem_chu'] ?? 'Chưa có'}'),
//                             ],
//                           ),
//                         ),
//                       )),
//                   const SizedBox(height: 16),
//                   // Học phần đang học
//                   const Text(
//                     'Học phần đang học',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   if (ongoingCourses.isEmpty)
//                     const Text('Không có học phần nào đang học.'),
//                   ...ongoingCourses.map((course) => Card(
//                         margin: const EdgeInsets.symmetric(vertical: 4.0),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                         child: ListTile(
//                           title: Text(
//                             course['title'],
//                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text('Tín chỉ: ${course['so_tin_chi']}'),
//                         ),
//                       )),
//                 ],
//               ),
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Lỗi: $error')),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';

class StudentProgressScreen extends ConsumerWidget {
  final int studentId;

  const StudentProgressScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(studentProgressProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Theo dõi tiến độ học tập'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(studentProgressProvider(studentId));
            },
          ),
        ],
      ),
      body: progressAsync.when(
        data: (progress) {
          final progressData = progress['courses'] as List<dynamic>;
          final totalCreditsCompleted = (progress['total_credits_completed'] as num).toDouble();
          final totalCredits = (progress['total_credits'] as num).toDouble();
          final gpa = (progress['gpa'] as num).toDouble();
          final progressPercentage = (progress['progress_percentage'] as num).toDouble();
          final requiredCredits = (progress['required_credits'] as num).toDouble();

          // Phân loại học phần
          final completedCourses = progressData.where((course) => course['is_completed'] == true).toList();
          final ongoingCourses = progressData.where((course) => course['is_completed'] != true).toList();

          // Tính tín chỉ hoàn thành từ học phần bình thường và học phần điều kiện
          final normalCompletedCredits = completedCourses
              .where((course) => course['is_condition_course'] == 0)
              .fold<double>(0.0, (sum, course) => sum + (course['so_tin_chi'] as num).toDouble());
          final conditionCompletedCredits = completedCourses
              .where((course) => course['is_condition_course'] == 1)
              .fold<double>(0.0, (sum, course) => sum + (course['so_tin_chi'] as num).toDouble());

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin tổng quan
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng quan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tín chỉ hoàn thành:', style: TextStyle(fontSize: 16)),
                              Text(
                                '${totalCreditsCompleted.toStringAsFixed(1)} / $requiredCredits',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tín chỉ học phần thường:', style: TextStyle(fontSize: 16)),
                              Text(
                                normalCompletedCredits.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tín chỉ học phần điều kiện:', style: TextStyle(fontSize: 16)),
                              Text(
                                conditionCompletedCredits.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Điểm trung bình (GPA):', style: TextStyle(fontSize: 16)),
                              Text(
                                gpa.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '(GPA không bao gồm học phần điều kiện)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tiến độ:', style: TextStyle(fontSize: 16)),
                              Text(
                                '${progressPercentage.toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: progressPercentage / 100,
                            backgroundColor: Colors.grey[300],
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Học phần đã hoàn thành
                  const Text(
                    'Học phần đã hoàn thành',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (completedCourses.isEmpty)
                    const Text('Chưa hoàn thành học phần nào.'),
                  ...completedCourses.map((course) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course['title'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (course['is_condition_course'] == 1)
                                const Chip(
                                  label: Text(
                                    'Điều kiện',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tín chỉ: ${course['so_tin_chi']}'),
                              Text('Điểm hệ số 4: ${course['diem_he_so_4']?.toStringAsFixed(1) ?? 'Chưa có'}'),
                              Text('Điểm chữ: ${course['diem_chu'] ?? 'Chưa có'}'),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  // Học phần đang học
                  const Text(
                    'Học phần đang học',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (ongoingCourses.isEmpty)
                    const Text('Không có học phần nào đang học.'),
                  ...ongoingCourses.map((course) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course['title'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (course['is_condition_course'] == 1)
                                const Chip(
                                  label: Text(
                                    'Điều kiện',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                ),
                            ],
                          ),
                          subtitle: Text('Tín chỉ: ${course['so_tin_chi']}'),
                        ),
                      )),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}