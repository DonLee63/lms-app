import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:study_management_app/models/notification.dart';
import '../repositories/notification_repository.dart';
import '../constants/apilist.dart';

// Provider cho NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(base);
});

// Provider để lấy danh sách thông báo cho sinh viên
final studentNotificationsProvider = FutureProvider.family<List<Notification>, int>((ref, studentId) async {
  final repository = ref.read(notificationRepositoryProvider);
  return await repository.getStudentNotifications(studentId);
});

// Provider để gửi thông báo (cho giảng viên)
final sendNotificationProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(notificationRepositoryProvider);
  final teacherId = params['teacherId'] as int;
  final classId = params['classId'] as int;
  final title = params['title'] as String;
  final file = params['file'] as http.MultipartFile;

  await repository.sendNotification(teacherId, classId, title, file);
});