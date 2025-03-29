
import '../models/profile.dart';

// final String base = 'http://127.0.0.1:8000/api/v1';
// final String base = 'http://localhost:8000/api/v1';
// final String base = 'http://10.0.2.2:8000/api/v1';
// final String base = 'http://192.168.88.162:8000/api/v1';
final String base = 'http://192.168.1.6:8000/api/v1';
final String url_image = 'http://192.168.1.6:8000/';

//------Đăng nhập, đăng ký------//
final String api_register = "$base/register";
final String api_login = "$base/login";
final String api_logout = "$base/logout";
final String api_student = "$base/student";
final String api_teacher = "$base/teacher";
final String api_forgot = "$base/password/forgot";
final String api_reset = "$base/password/reset";
final String api_loginGoogle = "$base/google-sign-in";




//------Profile------------//
final String api_profile = base + "/profile";
final String api_updateprofile = base +"/updateprofile"; 

//------UniverInfo------------//
final String api_nganhs = base + "/nganhs";
final String api_donvi = base +"/donvi";
final String api_chuyenNganh = base +"/chuyenNganh";
final String api_classes = base +"/classes";
final String api_get_classes = base +"/getclasses";





//-------Error-------//
const String severError = "Sever Error";
const String unauthorized = "Unauthorized";
const String somethingWentWrong = "Something went wrong";



Profile initialProfile =const Profile(full_name: '', username: '', phone: '', address: '', photo: '', email: '', id: 0);

