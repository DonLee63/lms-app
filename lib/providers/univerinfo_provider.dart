import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/phan_cong.dart';
import '../repositories/univerinfo_reponsitory.dart';

// Tạo một instance của repository
final univerInfoRepositoryProvider = Provider<UniverInfoRepository>((ref) {
  return UniverInfoRepository();
});

// Provider cho danh sách ngành (nganhsFutureProvider)
final nganhsFutureProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, donviId) async {
  final repository = ref.watch(univerInfoRepositoryProvider);
  return await repository.fetchNganhs(donviId);
});


// Provider cho danh sách đơn vị (donvis)
final donvisFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(univerInfoRepositoryProvider);
  return await repository.fetchDonVis();
});

// Provider cho danh sách chuyên ngành (chuyenNganhs)
final chuyenNganhFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(univerInfoRepositoryProvider);
  return await repository.fetchChuyenNganh();
});

// Provider cho danh sách lớp (classesFutureProvider)
final classesFutureProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, nganhId) async {
  final repository = ref.watch(univerInfoRepositoryProvider);
  return await repository.fetchClasses(nganhId);
});


final phanCongProvider = FutureProvider.family<List<PhanCong>, int>((ref, teacherId) async {
  final repository = ref.watch(univerInfoRepositoryProvider);
  return repository.fetchPhanCongByTeacherId(teacherId);
});
