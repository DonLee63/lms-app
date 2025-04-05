import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart'; // Thêm thư viện animate_do để tạo animation
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ Dark Mode

    return Scaffold(
      key: _scaffoldMessengerKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Màu xanh đậm chuyên nghiệp
        elevation: 0,
        title: const Text(
          'Điểm danh sinh viên',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Màu chữ trắng để luôn dễ đọc
          ),
        ),
        centerTitle: true,
      ),
      body: timetableAsync.when(
        data: (timetable) {
          final todayClasses = timetable.where((schedule) => schedule['ngay'] == today).toList();

          if (todayClasses.isEmpty) {
            return Center(
              child: Text(
                'Hôm nay không có buổi học nào.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: todayClasses.length,
            itemBuilder: (context, index) {
              final schedule = todayClasses[index];
              final tkbId = schedule['timetable_id'] as int?;
              final subjectName = schedule['title'] as String?;
              if (tkbId == null || subjectName == null) {
                return const SizedBox.shrink();
              }

              final attendanceStatusAsync = ref.watch(attendanceListProvider(tkbId));

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
                          isDarkMode ? Colors.grey[800]! : Colors.blue[50]!, // Gradient điều chỉnh theo chế độ
                          isDarkMode ? Colors.grey[900]! : Colors.white,
                        ],
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      title: Text(
                        subjectName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blue[900], // Màu chữ điều chỉnh
                        ),
                      ),
                      subtitle: Text(
                        'Ngày: ${schedule['ngay']} - Buổi: ${schedule['buoi']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
                        ),
                      ),
                      trailing: attendanceStatusAsync.when(
                        data: (attendanceData) {
                          final presentStudents = attendanceData["present"] as List<dynamic>? ?? [];
                          final isAttendanceOpen = attendanceData["is_open"] as bool? ?? false;
                          final hasMarked = presentStudents.any((student) => student['student_id'] == widget.studentId);

                          return hasMarked
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[600],
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đã điểm danh',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[600],
                                      ),
                                    ),
                                  ],
                                )
                              : isAttendanceOpen
                                  ? ScaleTransitionButton(
                                      onPressed: () => _scanQR(tkbId),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue[600]!,
                                              Colors.blue[800]!,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: const Text(
                                          'Quét QR',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.lock,
                                          color: Colors.red[600],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Điểm danh đã đóng',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                      ],
                                    );
                        },
                        loading: () => const CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                        error: (error, stack) => const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Lỗi: $error',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Màu chữ điều chỉnh
            ),
          ),
        ),
      ),
    );
  }
}

// Widget tùy chỉnh để thêm hiệu ứng scale khi nhấn
class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ScaleTransitionButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _ScaleTransitionButtonState createState() => _ScaleTransitionButtonState();
}

class _ScaleTransitionButtonState extends State<ScaleTransitionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
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
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ Dark Mode

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Màu xanh đậm chuyên nghiệp
        elevation: 0,
        title: const Text(
          'Quét mã QR để điểm danh',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Màu chữ trắng để luôn dễ đọc
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              await controller.stop();
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (_isProcessing) return; // Ngăn xử lý nhiều lần
              _isProcessing = true;

              final List<Barcode> barcodes = capture.barcodes;
              final barcode = barcodes.first; // Chỉ lấy mã QR đầu tiên
              if (barcode.rawValue == null) {
                await _handleScanComplete(false, 'Mã QR không hợp lệ');
                return;
              }

              try {
                final qrData = jsonDecode(barcode.rawValue!);
                final scannedTkbId = qrData['tkb_id'] as int?;
                final qrToken = qrData['qr_token'] as String?;

                if (scannedTkbId == null || qrToken == null) {
                  await _handleScanComplete(false, 'Mã QR không hợp lệ');
                  return;
                }

                if (scannedTkbId != widget.tkbId) {
                  await _handleScanComplete(false, 'Mã QR không khớp với buổi học này');
                  return;
                }

                await ref.read(markAttendanceProvider({
                  'tkb_id': widget.tkbId,
                  'student_id': widget.studentId,
                  'qr_token': qrToken,
                }).future);
                await _handleScanComplete(true, 'Điểm danh thành công!');
              } catch (e) {
                await _handleScanComplete(false, 'Lỗi: $e');
              } finally {
                _isProcessing = false; // Reset trạng thái sau khi xử lý xong
              }
            },
          ),
          // Overlay để hướng dẫn người dùng
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.black.withOpacity(0.5),
              child: const Text(
                'Đưa mã QR vào khung hình để điểm danh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Khung quét QR
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue[800]!,
                  width: 4.0,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
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