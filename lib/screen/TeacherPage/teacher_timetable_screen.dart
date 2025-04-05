import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
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
    await ref.refresh(teacherScheduleProvider(widget.teacherId).future);
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(teacherScheduleProvider(widget.teacherId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Lịch dạy',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshTimetable,
            tooltip: 'Làm mới',
          ),
        ],
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
      body: RefreshIndicator(
        onRefresh: _refreshTimetable,
        color: Colors.blue[700],
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        child: timetableAsync.when(
          data: (timetable) {
            if (timetable.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có lịch dạy',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final weeklyTimetables = _splitTimetableByWeek(List<Map<String, dynamic>>.from(timetable));
            final filteredTimetables = _filterCurrentAndNextWeek(weeklyTimetables);

            if (filteredTimetables.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có lịch dạy trong 2 tuần tới',
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: filteredTimetables.length,
              itemBuilder: (context, index) {
                final weekData = filteredTimetables[index];
                final startDate = weekData.first['ngay'];
                final endDate = weekData.last['ngay'];

                return FadeInUp(
                  duration: Duration(milliseconds: 600 + (index * 100)),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    elevation: 6.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            isDarkMode ? Colors.grey[800]! : Colors.blue[50]!,
                            isDarkMode ? Colors.grey[900]! : Colors.white,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tuần ${index == 0 ? 'hiện tại' : 'tiếp theo'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.blue[900],
                                  ),
                                ),
                                Text(
                                  '($startDate - $endDate)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 16.0,
                                dataRowHeight: 60.0,
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.blue[900]!,
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Buổi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ngày',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Thứ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Môn',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Tiết',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Lớp',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Địa điểm',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: weekData.asMap().entries.map<DataRow>((entry) {
                                  final int idx = entry.key;
                                  final item = entry.value;
                                  return DataRow(
                                    color: MaterialStateColor.resolveWith(
                                      (states) => idx % 2 == 0
                                          ? (isDarkMode ? Colors.grey[700]! : Colors.grey[200]!)
                                          : (isDarkMode ? Colors.grey[800]! : Colors.white),
                                    ),
                                    cells: [
                                      DataCell(
                                        Text(
                                          item['buoi'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item['ngay'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          getDayOfWeek(item['ngay']),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item['subject'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${item['tietdau']} - ${item['tietcuoi']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item['class_course'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item['location'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode ? Colors.green[300] : Colors.green[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  'Không thể tải lịch dạy. Vui lòng thử lại sau.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshTimetable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  List<List<Map<String, dynamic>>> _filterCurrentAndNextWeek(List<List<Map<String, dynamic>>> weeklyTimetables) {
    final now = DateTime.now();
    final currentStartOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Thứ Hai của tuần hiện tại
    final currentEndOfWeek = currentStartOfWeek.add(const Duration(days: 6)); // Chủ Nhật của tuần hiện tại
    final nextStartOfWeek = currentStartOfWeek.add(const Duration(days: 7)); // Thứ Hai của tuần tiếp theo
    final nextEndOfWeek = nextStartOfWeek.add(const Duration(days: 6)); // Chủ Nhật của tuần tiếp theo

    List<List<Map<String, dynamic>>> filteredTimetables = [];

    for (var week in weeklyTimetables) {
      final weekStartDate = DateTime.parse(week.first['ngay']);
      final weekEndDate = DateTime.parse(week.last['ngay']);

      // Kiểm tra xem tuần này có giao với tuần hiện tại hoặc tuần tiếp theo không
      if ((weekStartDate.isBefore(currentEndOfWeek) || weekStartDate.isAtSameMomentAs(currentEndOfWeek)) &&
              (weekEndDate.isAfter(currentStartOfWeek) || weekEndDate.isAtSameMomentAs(currentStartOfWeek)) ||
          (weekStartDate.isBefore(nextEndOfWeek) || weekStartDate.isAtSameMomentAs(nextEndOfWeek)) &&
              (weekEndDate.isAfter(nextStartOfWeek) || weekEndDate.isAtSameMomentAs(nextStartOfWeek))) {
        filteredTimetables.add(week);
      }
    }

    // Sắp xếp lại để tuần hiện tại lên đầu, tuần tiếp theo ở sau
    filteredTimetables.sort((a, b) => DateTime.parse(a.first['ngay']).compareTo(DateTime.parse(b.first['ngay'])));

    // Giới hạn tối đa 2 tuần
    return filteredTimetables.take(2).toList();
  }

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