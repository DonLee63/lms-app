import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';

class TeacherTimetableScreen extends ConsumerStatefulWidget {
  final int teacherId;

  const TeacherTimetableScreen({super.key, required this.teacherId});

  @override
  ConsumerState<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends ConsumerState<TeacherTimetableScreen> {
  @override
  void initState() {
    super.initState();
    _refreshTimetable();
  }

  Future<void> _refreshTimetable() async {
    // ignore: unused_result
    await ref.refresh(teacherScheduleProvider(widget.teacherId).future);
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(teacherScheduleProvider(widget.teacherId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch dạy của giảng viên'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTimetable,
        child: timetableAsync.when(
          data: (timetable) {
            if (timetable.isEmpty) {
              return const Center(child: Text('Không có lịch dạy.'));
            }

            final weeklyTimetables = _splitTimetableByWeek(List<Map<String, dynamic>>.from(timetable));

            return ListView.builder(
              itemCount: weeklyTimetables.length,
              itemBuilder: (context, index) {
                final weekData = weeklyTimetables[index];
                final startDate = weekData.first['ngay'];
                final endDate = weekData.last['ngay'];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Từ ngày $startDate đến ngày $endDate',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Buổi')),
                              DataColumn(label: Text('Ngày')),
                              DataColumn(label: Text('Thứ')),
                              DataColumn(label: Text('Môn')),
                              DataColumn(label: Text('Tiết')),
                              DataColumn(label: Text('Lớp')),
                              DataColumn(label: Text('Địa điểm')),
                            ],
                            rows: weekData.map<DataRow>((item) {
                              return DataRow(cells: [
                                DataCell(Text(item['buoi'])),
                                DataCell(Text(item['ngay'])),
                                DataCell(Text(getDayOfWeek(item['ngay']))),
                                DataCell(Text(item['subject'])),
                                DataCell(Text('${item['tietdau']} - ${item['tietcuoi']}')),
                                DataCell(Text(item['class_course'])),
                                DataCell(Text(item['location'])),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Lỗi: $error')),
        ),
      ),
    );
  }

  /// Tách thời khóa biểu thành từng tuần
  List<List<Map<String, dynamic>>> _splitTimetableByWeek(List<Map<String, dynamic>> timetable) {
    timetable.sort((a, b) => a['ngay'].compareTo(b['ngay']));
    List<List<Map<String, dynamic>>> weeklyTimetables = [];
    List<Map<String, dynamic>> currentWeek = [];

    DateTime? currentStartOfWeek;

    for (var item in timetable) {
      final DateTime itemDate = DateTime.parse(item['ngay']);
      final startOfWeek = itemDate.subtract(Duration(days: itemDate.weekday - 1));

      if (currentStartOfWeek == null || startOfWeek.isAfter(currentStartOfWeek)) {
        if (currentWeek.isNotEmpty) {
          weeklyTimetables.add(List.from(currentWeek));
          currentWeek.clear();
        }
        currentStartOfWeek = startOfWeek;
      }
      currentWeek.add(item);
    }

    if (currentWeek.isNotEmpty) {
      weeklyTimetables.add(currentWeek);
    }

    return weeklyTimetables;
  }

  /// Chuyển đổi ngày thành thứ trong tuần
  String getDayOfWeek(String date) {
    final DateTime dateTime = DateTime.parse(date);
    switch (dateTime.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }
}
