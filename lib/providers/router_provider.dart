import 'package:flutter_riverpod/flutter_riverpod.dart';

// Lớp lưu trữ trạng thái route
class RouteState {
  final String currentRoute;
  final String? previousRoute;

  RouteState({required this.currentRoute, this.previousRoute});

  RouteState copyWith({String? currentRoute, String? previousRoute}) {
    return RouteState(
      currentRoute: currentRoute ?? this.currentRoute,
      previousRoute: previousRoute ?? this.previousRoute,
    );
  }
}

class RouteNotifier extends StateNotifier<RouteState> {
  RouteNotifier()
      : super(RouteState(currentRoute: '/', previousRoute: null));

  // Cập nhật route khi điều hướng
  void updateRoute(String newRoute) {
    if (newRoute != state.currentRoute) {
      state = state.copyWith(
        currentRoute: newRoute,
        previousRoute: state.currentRoute,
      );
    }
  }

  // Quay lại route trước đó
  void popRoute() {
    if (state.previousRoute != null) {
      state = state.copyWith(
        currentRoute: state.previousRoute,
        previousRoute: null, // Xóa previousRoute nếu không cần giữ
      );
    }
  }
}

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>((ref) {
  return RouteNotifier();
});
