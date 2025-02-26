// ignore: file_names
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefData {
  static String prefName = "com.example.shopping";

  static String introAvailable = prefName + "isIntroAvailable";
  static String isLoggedIn = prefName + "isLoggedIn";
  static String token = prefName + "token";
  static Future<SharedPreferences> getPrefInstance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences;
  }

  static Future<bool> isIntroAvailable() async {
    SharedPreferences preferences = await getPrefInstance();
    bool isIntroAvailable = preferences.getBool(introAvailable) ?? true;
    return isIntroAvailable;
  }

  static setIntroAvailable(bool avail) async {
    SharedPreferences preferences = await getPrefInstance();
    preferences.setBool(introAvailable, avail);
  }

  static setLogIn(bool avail) async {
    SharedPreferences preferences = await getPrefInstance();
    preferences.setBool(isLoggedIn, avail);
  }

  static Future<bool> isLogIn() async {
    SharedPreferences preferences = await getPrefInstance();
    bool isIntroAvailable = preferences.getBool(isLoggedIn) ?? false;
    return isIntroAvailable;
  }

  //dinh nghi luu tru token
 static Future<void> setToken(String tokenValue) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(PrefData.token, tokenValue); // Thay vì 'token'
}

static Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(PrefData.token); // Thay vì 'token'
}


  // Example of how token should be saved after successful login
  static Future<void> saveLoginState(String token, Map<String, dynamic>? userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString(PrefData.token, token);

    if (userData != null) {
      await prefs.setString('userData', jsonEncode(userData)); // Lưu user data nếu cần
    }

    print('Login state saved. Token: $token');
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefData.token);
    await prefs.setBool('isLoggedIn', false);
    // Xóa các data khác nếu có
  }
}

//getuserID
Future<int> getuserID() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('UserID') ?? 0;
}

//logout
Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');

}

