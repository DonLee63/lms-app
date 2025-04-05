import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_management_app/router.dart';
import 'providers/theme_provider.dart';
import 'screen/AuthPage/login_screen.dart';

void main() async {
  // Đảm bảo các bindings được khởi tạo trước khi chạy ứng dụng
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.lightBlue,
          surface: Colors.blue[50]!,
          background: Colors.white,
        ),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 31, 106, 171)!,
          secondary: const Color.fromARGB(255, 22, 92, 183)!,
          surface: const Color.fromARGB(255, 0, 0, 0)!,
          background: Colors.grey[900]!,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash, // Đặt SplashScreen làm màn hình khởi động
      routes: AppRoutes.routes,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => LoginScreen());
      },
    );
  }
}
