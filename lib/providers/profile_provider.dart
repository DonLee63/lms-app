import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/apilist.dart';
import '../constants/enum.dart';
import '../models/profile.dart';

import '../repositories/profile_repository.dart';


class ProfileState {
  final Profile profile;
  final UpdateStatus updateStatus;
  final String? errorMessage; // Lưu trữ thông báo lỗi nếu có

  ProfileState({
    required this.profile,
    this.updateStatus = UpdateStatus.initial,
    this.errorMessage,
  });

  ProfileState copyWith({
    Profile? profile,
    UpdateStatus? updateStatus,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      updateStatus: updateStatus ?? this.updateStatus,
      errorMessage: errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': profile.toJson(),
      'updateStatus': updateStatus.name,
      'errorMessage': errorMessage,
    };
  }

  static ProfileState fromMap(Map<String, dynamic> map) {
    return ProfileState(
      profile: Profile.fromJson(map['profile']),
      updateStatus: UpdateStatus.values
          .firstWhere((e) => e.name == map['updateStatus']),
      errorMessage: map['errorMessage'],
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository)
      : super(ProfileState(
            profile: Profile(
                email: initialProfile.email,
                full_name: initialProfile.full_name,
                phone: initialProfile.phone,
                address: initialProfile.address,
                photo: initialProfile.photo,
                username: initialProfile.username,
                id: initialProfile.id,
            )));

  // Hàm để thiết lập profile ban đầu
  void setInitialProfile() {
    state = ProfileState(
        profile: Profile(
            email: initialProfile.email,
            full_name: initialProfile.full_name,
            phone: initialProfile.phone,
            address: initialProfile.address,
            photo: initialProfile.photo,
            username: initialProfile.username,
            id: initialProfile.id,
        ));
  }

  //Cập nhật profile trong trạng thái
  void updatefull_name(String newfull_name) {
    state = state.copyWith(
        profile: state.profile.copyWith(full_name: newfull_name));
  }

  void updateUsername(String newuser_name) {
    state = state.copyWith(
        profile: state.profile.copyWith(username: newuser_name));
  }
  void updatePhone(String newPhone) {
    state = state.copyWith(profile: state.profile.copyWith(phone: newPhone));
  }

  void updateAddress(String newAddress) {
    state =
        state.copyWith(profile: state.profile.copyWith(address: newAddress));
  }

  void updateAvatar(String newphoto) {
    state = state.copyWith(profile: state.profile.copyWith(photo: newphoto));
  }

  // Gửi yêu cầu cập nhật profile lên server
  Future<void> saveProfile() async {
    try {
      // Đang cập nhật
      state = state.copyWith(updateStatus: UpdateStatus.updating);

      final isSuccess = await _repository.updateProfile(state.profile);

      if (isSuccess) {
        // Cập nhật thành công
        state = state.copyWith(updateStatus: UpdateStatus.success);
      } else {
        // Cập nhật thất bại
        state = state.copyWith(
          updateStatus: UpdateStatus.failure,
          errorMessage: 'Failed to update profile',
        );
      }
    } catch (e) {
      // Lỗi xảy ra trong quá trình cập nhật
      state = state.copyWith(
        updateStatus: UpdateStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> uploadAndUpdatePhoto(File photoFile) async {
  try {
    state = state.copyWith(updateStatus: UpdateStatus.updating);
    
    // Upload ảnh và nhận về URL
    final photoUrl = await _repository.uploadPhoto(photoFile);
    
    if (photoUrl != null) {
      // Cập nhật state với URL ảnh mới
      state = state.copyWith(
        profile: state.profile.copyWith(photo: photoUrl),
        updateStatus: UpdateStatus.success,
      );
      
      // Lưu thông tin profile mới
      await saveProfile();
    } else {
      state = state.copyWith(
        updateStatus: UpdateStatus.failure,
        errorMessage: 'Failed to upload photo',
      );
    }
  } catch (e) {
    state = state.copyWith(
      updateStatus: UpdateStatus.failure,
      errorMessage: e.toString(),
    );
  }
}

  Future<void> fetchProfile() async {
    state = state.copyWith(updateStatus: UpdateStatus.updating);
    try {
      final response = await _repository.getProfile();
      state = state.copyWith(
        profile: response,
        updateStatus: UpdateStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        updateStatus: UpdateStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

void resetProfile() {
  // Reset lại dữ liệu profile khi người dùng đăng xuất
  state = state.copyWith(
    profile: null,  // Đặt lại profile về null
    updateStatus: UpdateStatus.initial,  // Trạng thái ban đầu
    errorMessage: '',  // Xóa thông báo lỗi
  );
}


}

// Provider cho ProfileNotifier
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

