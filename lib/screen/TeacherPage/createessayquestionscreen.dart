import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/essay_question.dart';
import '../../providers/exercise_provider.dart';

class CreateEssayQuestionScreen extends ConsumerStatefulWidget {
  final int hocphanId;

  const CreateEssayQuestionScreen({super.key, required this.hocphanId});

  @override
  ConsumerState<CreateEssayQuestionScreen> createState() => _CreateEssayQuestionScreenState();
}

class _CreateEssayQuestionScreenState extends ConsumerState<CreateEssayQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
      print("User ID: $_userId");
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      final question = TuluanCauhoi(
        content: _contentController.text,
        hocphanId: widget.hocphanId,
        userId: _userId!,
      );

      try {
        final createdQuestion = await ref.read(createEssayQuestionProvider(question).future);
        if (createdQuestion != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tạo câu hỏi tự luận thành công!")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo câu hỏi tự luận")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Nội dung câu hỏi"),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? "Vui lòng nhập nội dung" : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitQuestion,
                child: const Text("Tạo câu hỏi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}