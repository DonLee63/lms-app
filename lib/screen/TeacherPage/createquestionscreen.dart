import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/trac_nghiem_question.dart';
import '../../providers/exercise_provider.dart';

// Trang tạo câu hỏi
class CreateQuestionScreen extends ConsumerStatefulWidget {
  final int hocphanId;

  const CreateQuestionScreen({super.key, required this.hocphanId});

  @override
  ConsumerState<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends ConsumerState<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  List<Map<String, dynamic>> _answers = [];
  int? _userId;
  TracNghiemLoai? _selectedQuestionType; // Biến để lưu loại câu hỏi được chọn

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

  void _addAnswer() {
    setState(() {
      _answers.add({'content': '', 'is_correct': false});
    });
  }

  Future<void> _submitQuestion() async {
    if (_formKey.currentState!.validate() && _answers.length >= 2 && _selectedQuestionType != null) {
      final question = TracNghiemCauhoi(
        content: _contentController.text,
        hocphanId: widget.hocphanId,
        loaiId: _selectedQuestionType!.id, // Lấy ID từ loại câu hỏi được chọn
        userId: _userId!,
      );

      try {
        final createdQuestion = await ref.read(createQuestionProvider(question).future);
        if (createdQuestion != null) {
          for (var answer in _answers) {
            final newAnswer = TracNghiemDapan(
              tracnghiemId: createdQuestion.id!,
              content: answer['content'],
              isCorrect: answer['is_correct'],
            );
            await ref.read(createAnswerProvider(newAnswer).future);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tạo câu hỏi thành công!")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm ít nhất 2 đáp án và chọn loại câu hỏi")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionTypesAsync = ref.watch(questionTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Tạo câu hỏi trắc nghiệm")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: "Nội dung câu hỏi"),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập nội dung" : null,
                ),
                const SizedBox(height: 16),
                questionTypesAsync.when(
                  data: (types) => DropdownButtonFormField<TracNghiemLoai>(
                    decoration: const InputDecoration(labelText: "Loại câu hỏi"),
                    value: _selectedQuestionType,
                    items: types.map((type) {
                      return DropdownMenuItem<TracNghiemLoai>(
                        value: type,
                        child: Text(type.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedQuestionType = value;
                      });
                    },
                    validator: (value) => value == null ? "Vui lòng chọn loại câu hỏi" : null,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text("Lỗi: $e"),
                ),
                const SizedBox(height: 16),
                const Text("Đáp án:", style: TextStyle(fontWeight: FontWeight.bold)),
                ..._answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "Đáp án ${index + 1}"),
                            onChanged: (value) => answer['content'] = value,
                            validator: (value) => value!.isEmpty ? "Vui lòng nhập đáp án" : null,
                          ),
                        ),
                        Checkbox(
                          value: answer['is_correct'],
                          onChanged: (value) {
                            setState(() {
                              answer['is_correct'] = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addAnswer,
                  child: const Text("Thêm đáp án"),
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
      ),
    );
  }
}