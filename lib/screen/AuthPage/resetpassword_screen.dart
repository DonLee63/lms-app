import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/apilist.dart';

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void resetPassword(String email, String token, String password) async {
    final response = await http.post(
      Uri.parse(api_reset),
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': password,
      },
    );

    if (response.statusCode == 200) {
      print('Password reset successful.');
    } else {
      print('Failed to reset password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: tokenController,
              decoration: InputDecoration(labelText: 'Token'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                resetPassword(
                  emailController.text,
                  tokenController.text,
                  passwordController.text,
                );
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
