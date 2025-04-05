import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
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
            SnackBar(content: const Text("Tạo câu hỏi tự luận thành công!"), backgroundColor: Colors.green[700]),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Tạo câu hỏi tự luận',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Card(
                elevation: 6.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Nội dung câu hỏi',
                          prefixIcon: Icon(Icons.edit, color: Colors.blue[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        ),
                        maxLines: 5,
                        validator: (value) => value!.isEmpty ? "Vui lòng nhập nội dung" : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _submitQuestion,
                        icon: const Icon(Icons.save),
                        label: const Text("Tạo câu hỏi"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 50),
                          elevation: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}