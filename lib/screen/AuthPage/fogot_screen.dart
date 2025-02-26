import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/apilist.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  void sendResetLink(String email) async {
    final response = await http.post(
      Uri.parse(api_forgot),
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      print('Reset link sent.');
    } else {
      print('Failed to send reset link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            ElevatedButton(
              onPressed: () {
                sendResetLink(emailController.text);
              },
              child: Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}
