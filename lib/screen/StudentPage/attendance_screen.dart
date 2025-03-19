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

  void _scanQR(int tkbId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          tkbId: tkbId,
          studentId: widget.studentId,
          onScanComplete: (success) {
            if (success) {
              ref.invalidate(attendanceListProvider(tkbId));
            }
          },
        ),
      ),
    );
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
}

// Trang quét QR riêng
class QRScannerScreen extends ConsumerStatefulWidget {
  final int tkbId;
  final int studentId;
  final Function(bool) onScanComplete;

  const QRScannerScreen({
    super.key,
    required this.tkbId,
    required this.studentId,
    required this.onScanComplete,
  });

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  late MobileScannerController controller;
  bool _isProcessing = false; // Biến để tránh xử lý nhiều lần

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  Future<void> _handleScanComplete(bool success, String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    await controller.stop(); // Dừng camera trước khi thoát
    if (mounted) {
      Navigator.pop(context);
      widget.onScanComplete(success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quét mã QR để điểm danh"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await controller.stop();
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) async {
                if (_isProcessing) return; // Ngăn xử lý nhiều lần
                _isProcessing = true;

                final List<Barcode> barcodes = capture.barcodes;
                final barcode = barcodes.first; // Chỉ lấy mã QR đầu tiên
                if (barcode.rawValue == null) {
                  await _handleScanComplete(false, "Mã QR không hợp lệ");
                  return;
                }

                try {
                  final qrData = jsonDecode(barcode.rawValue!);
                  final scannedTkbId = qrData['tkb_id'] as int?;
                  final qrToken = qrData['qr_token'] as String?;

                  if (scannedTkbId == null || qrToken == null) {
                    await _handleScanComplete(false, "Mã QR không hợp lệ");
                    return;
                  }

                  if (scannedTkbId != widget.tkbId) {
                    await _handleScanComplete(false, "Mã QR không khớp với buổi học này");
                    return;
                  }

                  await ref.read(markAttendanceProvider({
                    "tkb_id": widget.tkbId,
                    "student_id": widget.studentId,
                    "qr_token": qrToken,
                  }).future);
                  await _handleScanComplete(true, "Điểm danh thành công!");
                } catch (e) {
                  await _handleScanComplete(false, "Lỗi: $e");
                } finally {
                  _isProcessing = false; // Reset trạng thái sau khi xử lý xong
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}