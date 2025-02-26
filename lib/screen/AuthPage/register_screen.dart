import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_management_app/screen/AuthPage/login_screen.dart';
import '../../constants/pref_data.dart';
import '../../models/user.dart';
import '../../providers/registration_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/google_provider.dart';
import '../policy_screen.dart';
import '../TeacherPage/teacher_screen.dart';
import '../StudentPage/student_screen.dart';

class SignupPage extends ConsumerStatefulWidget {
  SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isAgreed = false;
  String _selectedRole = 'student';

  // Register User
  void _registerUser() async {
  if (!_formKey.currentState!.validate() || !_isAgreed) {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the terms and policies.")),
      );
    }
    return;
  }

  setState(() {
    _isLoading = true;
  });

  final user = User(
    email: _emailController.text.trim(),
    password: _passwordController.text,
    full_name: _fullNameController.text.trim(),
    phone: _phoneController.text.trim(),
    role: _selectedRole,
  );

  // Gọi hàm đăng ký
  await ref.read(registrationProvider.notifier).register(user);
  final registrationStatus = ref.watch(registrationProvider);

  if (registrationStatus == RegistrationStatus.success) {
    // Lấy token từ RegistrationNotifier
    final registrationNotifier = ref.read(registrationProvider.notifier);
    final token = registrationNotifier.token;

    if (token != null) {
      // Lưu trạng thái đăng nhập
      await PrefData.setToken(token);

      // Lấy thông tin user mới
      await ref.read(profileProvider.notifier).fetchProfile();

      // Chuyển hướng
      _redirectToHome();
    } else {
      _showErrorSnackBar("Failed to retrieve token.");
    }
  } else {
    String errorMsg = ref.read(registrationProvider.notifier).errorMessage ?? "Registration failed.";
    _showErrorSnackBar(errorMsg);
  }

  setState(() {
    _isLoading = false;
  });
}



  // Redirect to Home
  void _redirectToHome() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('isLoggedIn', true);
    await pref.setString('userRole', _selectedRole);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => _selectedRole == 'teacher' ? TeacherScreen() : StudentScreen(),
      ),
      (route) => false,
    );
  }

  // Show SnackBar Error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Sign up",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Create an account, it's free",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          _fullNameController,
                          "Full Name",
                          "Please enter your full name",
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _emailController,
                          "Email",
                          "Please enter your email",
                          isEmail: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _passwordController,
                          "Password",
                          "Please enter your password",
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _confirmPasswordController,
                          "Confirm Password",
                          "Passwords do not match",
                          isPassword: true,
                          isConfirmPassword: true,
                        ),
                        // const SizedBox(height: 20),
                        // _buildTextField(
                        //   _phoneController,
                        //   "Phone",
                        //   "Please enter your phone number",
                        // ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'student', child: Text('Student')),
                            DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedRole = value!),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a role'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _isAgreed,
                              onChanged: (value) =>
                                  setState(() => _isAgreed = value ?? false),
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  const Text("I agree to the"),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PolicyScreen()),
                                    ),
                                    child: const Text(
                                      " terms and policies ",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const Text("of the application."),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  _buildSignUpButton(),
                                  const SizedBox(height: 20),
                                  _buildGoogleSignInButton(ref), // Google Sign-In Button
                                ],
                              ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        ),
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

// Update _buildTextField method to include confirmation password validation
Widget _buildTextField(TextEditingController controller, String label, String error,
    {bool isEmail = false, bool isPassword = false, bool isConfirmPassword = false}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
    obscureText: isPassword || isConfirmPassword,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return error;
      }
      if (isConfirmPassword && value != _passwordController.text) {
        return "Passwords do not match";
      }
      return null;
    },
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

          // Hiển thị hộp thoại yêu cầu người dùng chọn role (student hoặc teacher)
          final selectedRole = await _showRoleSelectionDialog(context);

          if (selectedRole == null) {
            // Nếu người dùng không chọn role, không tiếp tục
            return;
          }

          // Gọi hàm signInWithGoogle với role người dùng chọn
          await ref.read(googleAuthProvider.notifier).signUpWithGoogle(role: selectedRole);

          // Kiểm tra trạng thái đăng nhập sau khi thực hiện
          if (ref.read(googleAuthProvider) == GoogleAuthStatus.success) {
            final userId = ref.read(googleAuthProvider.notifier).userId;
            final token = ref.read(googleAuthProvider.notifier).token;
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setBool('isLoggedIn', true);
            await pref.setString('userRole', selectedRole);
            if (userId != null && token != null) {
              await ref.read(profileProvider.notifier).fetchProfile(); 
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Đăng kí thành công ")),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                builder: (context) => selectedRole == 'teacher' ? TeacherScreen() : StudentScreen(),
                ),
                (route) => false,
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

// Hàm hiển thị hộp thoại chọn role
Future<String?> _showRoleSelectionDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Chọn vai trò"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Student"),
              onTap: () => Navigator.pop(context, "student"),
            ),
            ListTile(
              title: Text("Teacher"),
              onTap: () => Navigator.pop(context, "teacher"),
            ),
          ],
        ),
      );
    },
  );
}



  // Helper: Build SignUp Button
  Widget _buildSignUpButton() {
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
        onPressed: _registerUser,
        color: const Color.fromARGB(255, 50, 84, 255),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Text(
          "Sign up",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
