import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/constants/pref_data.dart';
import 'package:study_management_app/screen/AuthPage/fogot_screen.dart';
import '../../providers/profile_provider.dart';
import '../../repositories/auth_repository.dart';
import '../../navigation/main_page.dart';
import 'register_screen.dart';
import '../../providers/google_provider.dart'; // Import Google provider

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    // Gọi AuthRepository để xử lý đăng nhập
    try {
      bool isLoggedIn = await AuthRepository().login(
        _emailController.text,
        _passwordController.text,
      );

      if (isLoggedIn) {
        // Lấy token từ SharedPreferences
        SharedPreferences pref = await SharedPreferences.getInstance();
        String? token = pref.getString(PrefData.token); // Thay vì 'token'

        if (token != null && token.isNotEmpty) {
          // Lấy thông tin người dùng sau khi đăng nhập thành công
          await ref.read(profileProvider.notifier).fetchProfile(); // Lưu ý sử dụng `ref.read`

          // Sau khi đã lấy thông tin người dùng, thực hiện chuyển hướng
          _saveAndRedirectToHome(token);
        } else {
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to retrieve token. Please try again.')),
          );
        }
      } else {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please check your credentials.')),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _saveAndRedirectToHome(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('isLoggedIn', true);
    await pref.setString('token', token);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Welcome back, login to continue",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 3, left: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: const Border(
                                    bottom: BorderSide(color: Colors.black),
                                    top: BorderSide(color: Colors.black),
                                    left: BorderSide(color: Colors.black),
                                    right: BorderSide(color: Colors.black),
                                  ),
                                ),
                                child: MaterialButton(
                                  minWidth: double.infinity,
                                  height: 60,
                                  onPressed: _loginUser,
                                  color: const Color.fromARGB(255, 50, 84, 255),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildGoogleSignInButton(ref), // Google Sign-In Button
                            ],
                          ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                      },
                      child: const Text("Quên mật khẩu"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignupPage()));
                          },
                          child: const Text("Sign up"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Google Sign-In Button
 Widget _buildGoogleSignInButton(WidgetRef ref) {
  return Container(
    padding: const EdgeInsets.only(top: 3, left: 3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      border: const Border(
        bottom: BorderSide(color: Colors.black),
        top: BorderSide(color: Colors.black),
        left: BorderSide(color: Colors.black),
        right: BorderSide(color: Colors.black),
      ),
    ),
    child: MaterialButton(
      minWidth: double.infinity,
      height: 60,
      onPressed: () async {
        try {
          // Đọc trạng thái từ provider
          final googleAuthStatus = ref.read(googleAuthProvider);
          
          if (googleAuthStatus == GoogleAuthStatus.loading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đang đăng nhập...")),
            );
            return;
          }

          // Gọi hàm signInWithGoogle
          await ref.read(googleAuthProvider.notifier).signInWithGoogle();

          // Kiểm tra trạng thái đăng nhập sau khi thực hiện
          if (ref.read(googleAuthProvider) == GoogleAuthStatus.success) {
            final userId = ref.read(googleAuthProvider.notifier).userId;
            final token = ref.read(googleAuthProvider.notifier).token;
            print ('tokentoken: $token');
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setBool('isLoggedIn', true);
            if (userId != null && token != null) {
              await ref.read(profileProvider.notifier).fetchProfile(); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đăng nhập thành công")),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainPage(),
                ),
              );
            }
          } else if (ref.read(googleAuthProvider) == GoogleAuthStatus.error) {
            final errorMessage = ref.read(googleAuthProvider.notifier).errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $errorMessage")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      },
      color: Colors.red,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: const Text(
        "Sign in with Google",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
      ),
    ),
  );
}
}

