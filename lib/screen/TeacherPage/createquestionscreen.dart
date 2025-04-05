import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/trac_nghiem_question.dart';
import '../../providers/exercise_provider.dart';

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
  TracNghiemLoai? _selectedQuestionType;

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

  void _addAnswer() {
    setState(() {
      _answers.add({'content': '', 'is_correct': false});
    });
  }

  void _removeAnswer(int index) {
    setState(() {
      _answers.removeAt(index);
    });
  }

  Future<void> _submitQuestion() async {
    if (_formKey.currentState!.validate() && _answers.length >= 2 && _selectedQuestionType != null) {
      final question = TracNghiemCauhoi(
        content: _contentController.text,
        hocphanId: widget.hocphanId,
        loaiId: _selectedQuestionType!.id,
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
            SnackBar(content: const Text("Tạo câu hỏi thành công!"), backgroundColor: Colors.green[700]),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red[700]),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm ít nhất 2 đáp án và chọn loại câu hỏi"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionTypesAsync = ref.watch(questionTypesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Tạo câu hỏi trắc nghiệm',
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
                          prefixIcon: Icon(Icons.question_answer, color: Colors.blue[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        ),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? "Vui lòng nhập nội dung" : null,
                      ),
                      const SizedBox(height: 16),
                      questionTypesAsync.when(
                        data: (types) => DropdownButtonFormField<TracNghiemLoai>(
                          decoration: InputDecoration(
                            labelText: 'Loại câu hỏi',
                            prefixIcon: Icon(Icons.category, color: Colors.blue[700]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          ),
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
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                          ),
                        ),
                        error: (e, _) => Text("Lỗi: $e", style: TextStyle(color: Colors.red[700])),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Đáp án',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._answers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final answer = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Đáp án ${index + 1}',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                  ),
                                  onChanged: (value) => answer['content'] = value,
                                  validator: (value) => value!.isEmpty ? "Vui lòng nhập đáp án" : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Checkbox(
                                value: answer['is_correct'],
                                activeColor: Colors.green[700],
                                onChanged: (value) {
                                  setState(() {
                                    answer['is_correct'] = value ?? false;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[700]),
                                onPressed: () => _removeAnswer(index),
                                tooltip: 'Xóa đáp án',
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addAnswer,
                            icon: const Icon(Icons.add),
                            label: const Text("Thêm đáp án"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4.0,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _submitQuestion,
                            icon: const Icon(Icons.save),
                            label: const Text("Tạo câu hỏi"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4.0,
                            ),
                          ),
                        ],
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