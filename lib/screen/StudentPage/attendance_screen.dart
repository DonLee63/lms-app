import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../../providers/attendance_provider.dart';
import '../../providers/course_provider.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  final int studentId;

  const StudentAttendanceScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> {
  MobileScannerController? controller;
  late GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  @override
  void initState() {
    super.initState();
    _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final timetable = ref.read(timetableProvider(widget.studentId)).valueOrNull;
    if (timetable != null) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      for (var schedule in timetable) {
        if (schedule['ngay'] == today && schedule['timetable_id'] != null) {
          ref.invalidate(attendanceListProvider(schedule['timetable_id']));
        }
      }
    }
  }

  Future<void> _scanQR(int tkbId) async {
    controller = MobileScannerController();
    await showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      final qrData = jsonDecode(barcode.rawValue!);
                      final scannedTkbId = qrData['tkb_id'] as int?;
                      final qrToken = qrData['qr_token'] as String?;

                      if (scannedTkbId == null || qrToken == null) {
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(content: Text("Mã QR không hợp lệ")),
                        );
                        if (mounted) Navigator.pop(context);
                        return;
                      }

                      if (scannedTkbId != tkbId) {
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(content: Text("Mã QR không khớp với buổi học này")),
                        );
                        if (mounted) Navigator.pop(context);
                        return;
                      }

                      try {
                        await ref.read(markAttendanceProvider({
                          "tkb_id": tkbId,
                          "student_id": widget.studentId,
                          "qr_token": qrToken,
                        }).future);
                        ref.invalidate(attendanceListProvider(tkbId));
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(content: Text("Điểm danh thành công!"), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                        );
                      }
                      if (mounted) Navigator.pop(context);
                      break;
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  controller?.stop();
                  Navigator.pop(context);
                },
                child: const Text("Hủy"),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() => controller?.start());
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(timetableProvider(widget.studentId));
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(title: const Text("Điểm danh sinh viên")),
      body: timetableAsync.when(
        data: (timetable) {
          final todayClasses = timetable.where((schedule) => schedule['ngay'] == today).toList();

          if (todayClasses.isEmpty) {
            return const Center(child: Text("Hôm nay không có buổi học nào."));
          }

          return ListView.builder(
            itemCount: todayClasses.length,
            itemBuilder: (context, index) {
              final schedule = todayClasses[index];
              final tkbId = schedule['timetable_id'] as int?;
              final subjectName = schedule['title'] as String?;
              if (tkbId == null || subjectName == null) {
                return const SizedBox.shrink();
              }

              final attendanceStatusAsync = ref.watch(attendanceListProvider(tkbId));

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Ngày: ${schedule['ngay']} - Buổi: ${schedule['buoi']}"),
                  trailing: attendanceStatusAsync.when(
                    data: (attendanceData) {
                      final presentStudents = attendanceData["present"] as List<dynamic>? ?? [];
                      final isAttendanceOpen = attendanceData["is_open"] as bool? ?? false;
                      final hasMarked = presentStudents.any((student) => student['student_id'] == widget.studentId);

                      return hasMarked
                          ? const Text("✅ Đã điểm danh", style: TextStyle(color: Colors.green))
                          : isAttendanceOpen
                              ? ElevatedButton(
                                  onPressed: () => _scanQR(tkbId),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                  child: const Text("Quét QR"),
                                )
                              : const Text("🚫 Điểm danh đã đóng", style: TextStyle(color: Colors.red));
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Lỗi: $error")),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}