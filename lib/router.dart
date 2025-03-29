import 'package:flutter/material.dart';
import 'package:study_management_app/screen/AuthPage/login_screen.dart';
import 'package:study_management_app/screen/ProfilePage/edit_profile_screen.dart';
import 'package:study_management_app/screen/ProfilePage/profile_screen.dart';
import 'package:study_management_app/screen/StudentPage/student_enrolled_courses.dart';
import 'package:study_management_app/screen/StudentPage/student_exercises_screen.dart';
import 'package:study_management_app/screen/StudentPage/student_info_screen.dart';
import 'package:study_management_app/screen/StudentPage/student_scores_courses.dart';
import 'package:study_management_app/screen/StudentPage/student_screen.dart';
import 'package:study_management_app/screen/StudentPage/student_survey_list_screen.dart';
import 'package:study_management_app/screen/TeacherPage/enter_scores_screen.dart';
import 'package:study_management_app/screen/TeacherPage/phan_cong_screen.dart';
import 'package:study_management_app/screen/TeacherPage/student_list_screen.dart';
import 'package:study_management_app/screen/TeacherPage/course_class_screen.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_hocphan_screen.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_info_screen.dart';
import 'package:study_management_app/screen/TeacherPage/teacher_screen.dart';
import 'package:study_management_app/screen/StudentPage/exam_schedule_screen.dart';
import 'package:study_management_app/screen/home_screen.dart';
import 'package:study_management_app/screen/notifications_screen.dart';
import 'package:study_management_app/screen/policy_screen.dart';
import 'package:study_management_app/screen/StudentPage/timetable_screen.dart';
import 'package:study_management_app/screen/settings_screen.dart';
import 'package:study_management_app/navigation/main_page.dart';
import 'package:study_management_app/screen/StudentPage/edit_student_screen.dart';
import 'package:study_management_app/screen/TeacherPage/edit_teacher_screen.dart';
import 'package:study_management_app/screen/splash_screen.dart';

import 'screen/StudentPage/enrolled_course_screen.dart';
import 'screen/StudentPage/register_course_sreen.dart';
import 'screen/TeacherPage/teacher_timetable_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String mainpage = '/main_page';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgot = '/forgot';
  static const String resetpassword = '/reset_password';
  static const String profile = '/profile';
  static const String notification = '/notification';
  static const String examschedule = '/exam_schedule';
  static const String policy = '/policy';
  // static const String search = '/search';
  static const String settings = '/settings';
  static const String editprofile = '/edit_profile';
  static const String editstudent = '/edit_student';
  static const String studentscreen = '/student_screen';
  static const String studentinfo = '/student_info';
  static const String teacherscreen = '/teacher_screen';
  static const String editteacher = '/edit_teacher';
  static const String teacherinfo = '/teacher_info';

  //Course
  static const String courses = '/courses';
  static const String searchCourses = '/searchCourses';
  static const String enroll = '/enroll';
  static const String getEnroll = '/getEnroll';
  static const String deleteEnroll = '/deleteEnroll';
  static const String timeTable = '/timeTable';
  static const String teacherTimetable = '/lichday';
  static const String phancong = '/phancong';
  static const String getClass = '/getClass';
  static const String studentSurvey = '/studentSurvey';
  static const String studentExercises = '/studentExercises';
  static const String courseClass = '/courseClass';
  static const String studentenrolled = '/studentenrolled';
  static const String enterScores = '/enterScores';
  static const String teacherhocphan = '/teacherhocphan';
  static const String studentscorecourse = '/studentscorecourse';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    home: (context) => const HomeScreen(),
    mainpage: (context) => const MainPage(),
    login: (context) => LoginScreen(),
    profile: (context) => ProfileScreen(),
    notification: (context) => const NotificationsScreen(),
    policy: (context) => const PolicyScreen(),
    settings: (context) => const SettingsScreen(),
    studentscreen: (context) => StudentScreen(),
    teacherscreen: (context) => TeacherScreen(),
    editprofile: (context) => const EditProfileScreen(),
    enterScores: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, int>;
        final hocphanId = args['hocphanId'] ?? 0;
        final teacherId = args['teacherId'] ?? 0;
        final phancongId = args['phancongId'] ?? 0;
        return EnterScoresScreen(hocphanId: hocphanId, teacherId: teacherId, phancongId: phancongId);
      } else {
        return const HomeScreen();
      }
    },
     teacherhocphan: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final teacherId = ModalRoute.of(context)!.settings.arguments as int;
        return TeacherHocPhanScreen(teacherId: teacherId);
      } else {
        return const HomeScreen();
      }
    },
    studentSurvey: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final studentId = ModalRoute.of(context)!.settings.arguments as int;
        return StudentSurveyListScreen(studentId: studentId);
      } else {
        return const HomeScreen();
      }
    },
    studentscorecourse: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final studentId = ModalRoute.of(context)!.settings.arguments as int;
        return StudentScoresCourses(studentId: studentId);
      } else {
        return const HomeScreen();
      }
    },
    studentExercises:(context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final studentId = ModalRoute.of(context)!.settings.arguments as int;
        return StudentExercisesScreen(studentId: studentId);
      } else {
        return const HomeScreen();
      }
    },
    studentenrolled:(context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final studentId = ModalRoute.of(context)!.settings.arguments as int;
        return StudentEnrolledCourses(studentId: studentId);
      } else {
        return const HomeScreen();
      }
    },
    courseClass: (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, int>) {
      final int teacherId = args['teacherId'] ?? 0;  // Lấy teacherId từ Map
      final int phancongId = args['phancongId'] ?? 0;  // Lấy phancongId từ Map
      return CourseClassScreen(teacherId: teacherId, phancongId: phancongId);
    } else {
      return const HomeScreen();
    }
  },

    editstudent: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final userId = ModalRoute.of(context)!.settings.arguments as int;
        return EditStudentScreen(userId: userId);
      } else {
        return const StudentInfoScreen();
      }
    },
    editteacher: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final userId = ModalRoute.of(context)!.settings.arguments as int;
        return EditTeacherScreen(userId: userId);
      } else {
        return const TeacherInfoScreen();
      }
    },
    studentinfo: (context) => const StudentInfoScreen(),
    teacherinfo: (context) => const TeacherInfoScreen(),
    phancong: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final teacherId = ModalRoute.of(context)!.settings.arguments as int;
        return PhanCongScreen(teacherId: teacherId);
      } else {
        return const HomeScreen();
      }
    },
   courses: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final studentId = ModalRoute.of(context)!.settings.arguments as int;
        return RegisterCourseScreen(studentId: studentId);
      } else {
        return const HomeScreen();
      }
    },
    enroll: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final studentId = ModalRoute.of(context)!.settings.arguments as int;
        return EnrolledCourseScreen(studentId: studentId);
      } else {
        return const HomeScreen();
      }
    },

    timeTable: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final studentId = ModalRoute.of(context)!.settings.arguments as int;
        return TimetableScreen(studentId: studentId);
      } else {
        return const HomeScreen();
      }
    },
    teacherTimetable: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final teacherId = ModalRoute.of(context)!.settings.arguments as int;
        return TeacherTimetableScreen(teacherId: teacherId);
      } else {
        return const HomeScreen();
      }
    },

    examschedule:  (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final studentId = ModalRoute.of(context)!.settings.arguments as int;
        return ExamScheduleScreen(studentId: studentId);
      } else {
        return const HomeScreen();
      }
    },

    getClass: (context) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final teacherId = ModalRoute.of(context)!.settings.arguments as int;
        return StudentListScreen(teacherId: teacherId);
      } else {
        return const HomeScreen();
      }
    },
  };

}
 