import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/StudentPage/attendance_screen.dart';
import '../screen/TeacherPage/teacher_timetable_screen.dart';
import '../screen/home_screen.dart';
import '../screen/StudentPage/timetable_screen.dart';
import '../screen/notifications_screen.dart';
import '../screen/settings_screen.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _currentIndex = 0;
  int? _studentId;
  int? _teacherId;
  String? _role;

  List<Widget> _pages = [const HomeScreen()]; // Luôn có ít nhất 1 trang

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndIds();
  }

  Future<void> _loadUserRoleAndIds() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final studentId = prefs.getInt('student_id');
    final teacherId = prefs.getInt('teacher_id');

    if (role != null) {
      setState(() {
        _role = role;
        _studentId = studentId;
        _teacherId = teacherId;
        _initializePages();
      });
    }
  }

  void _initializePages() {
    List<Widget> pages = [const HomeScreen()];

    if (_role == 'student' && _studentId != null) {
      pages.add(TimetableScreen(studentId: _studentId!));
      pages.add(StudentAttendanceScreen(studentId: _studentId!));
    } else if (_role == 'teacher' && _teacherId != null) {
      pages.add(TeacherTimetableScreen(teacherId: _teacherId!));
    }

    pages.addAll([
      const NotificationsScreen(),
      const SettingsScreen(),
    ]);

    setState(() {
      _pages = pages;
      // Đảm bảo _currentIndex hợp lệ
      if (_currentIndex >= _pages.length) {
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: (_role == null || _pages.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        items: _buildBottomNavigationItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavigationItems() {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
    ];

    if (_role == 'student' && _studentId != null) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'TKB',
      ));
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Điểm danh',
      ));
    } else if (_role == 'teacher' && _teacherId != null) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Lịch dạy',
      ));
    }

    items.addAll([
      const BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: 'Notifications',
      ),
      
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ]);

    return items;
  }
}
