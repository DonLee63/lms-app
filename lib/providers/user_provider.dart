import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserId(int userId) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setInt('userId', userId);
}

Future<int?> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId');
}