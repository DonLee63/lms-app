import 'package:flutter/material.dart';

class StudentExercisesScreen extends StatelessWidget {
  const StudentExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Bài tập'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
              Navigator.of(context).pop();  // Quay lại trang trước
          },
        ),
      ),
      body: const Center(
        child: Text(
          'Bài tập',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
