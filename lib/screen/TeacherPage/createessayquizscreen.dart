import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/essay_question.dart';
import '../../providers/exercise_provider.dart';

class CreateEssayQuizScreen extends ConsumerStatefulWidget {
  final int hocphanId;

  const CreateEssayQuizScreen({super.key, required this.hocphanId});

  @override
  ConsumerState<CreateEssayQuizScreen> createState() => _CreateEssayQuizScreenState();
}

class _CreateEssayQuizScreenState extends ConsumerState<CreateEssayQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _totalPointsController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  List<Map<String, dynamic>> _selectedQuestions = [];
  int _userId = 1;
  late Future<List<TuluanCauhoi>> _questionsFuture = _loadQuestions();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
      _questionsFuture = ref.read(exerciseRepositoryProvider).getEssayQuestionsByHocphan(widget.hocphanId, _userId);
    });
  }

  Future<List<TuluanCauhoi>> _loadQuestions() async {
    return ref.read(exerciseRepositoryProvider).getEssayQuestionsByHocphan(widget.hocphanId, _userId);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _totalPointsController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStart) _startTime = selectedDateTime;
          else _endTime = selectedDateTime;
        });
      }
    }
  }

  void _submitQuiz() async {
  if (_formKey.currentState!.validate() && _startTime != null && _endTime != null && _selectedQuestions.isNotEmpty) {
    final quiz = BodeTuluan(
      title: _titleController.text,
      hocphanId: widget.hocphanId,
      slug: "${_titleController.text.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}",
      startTime: _startTime!,
      endTime: _endTime!,
      time: int.parse(_timeController.text),
      totalPoints: int.parse(_totalPointsController.text),
      questions: _selectedQuestions, // Đảm bảo là List<Map<String, dynamic>>
      userId: _userId,
    );

    try {
      print("Submitting quiz: ${quiz.toJson()}"); // Log để kiểm tra
      final createdQuiz = await ref.read(createEssayQuizProvider(quiz).future);
      if (createdQuiz != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo bộ đề tự luận thành công!")),
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
      const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo bộ đề tự luận")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Tiêu đề bộ đề"),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập tiêu đề" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: "Thời gian làm bài (phút)"),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập thời gian" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _totalPointsController,
                  decoration: const InputDecoration(labelText: "Tổng điểm"),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập tổng điểm" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(_startTime != null
                          ? "Bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm').format(_startTime!)}"
                          : "Chọn thời gian bắt đầu"),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDateTime(context, true),
                      child: const Text("Chọn"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(_endTime != null
                          ? "Kết thúc: ${DateFormat('dd/MM/yyyy HH:mm').format(_endTime!)}"
                          : "Chọn thời gian kết thúc"),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDateTime(context, false),
                      child: const Text("Chọn"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Chọn câu hỏi:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 200,
                  child: FutureBuilder<List<TuluanCauhoi>>(
                    future: _questionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Lỗi: ${snapshot.error}"));
                      }
                      final questions = snapshot.data ?? [];
                      if (questions.isEmpty) {
                        return const Center(child: Text("Không có câu hỏi nào"));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final questionId = question.id;
                          if (questionId == null) {
                            return ListTile(
                              title: Text(question.content),
                              subtitle: const Text("ID: Không xác định"),
                              enabled: false, // Không cho chọn nếu id null
                            );
                          }
                          return CheckboxListTile(
                            title: Text(question.content),
                            subtitle: Text("ID: $questionId"),
                            value: _selectedQuestions.any((q) => q['id_question'] == questionId),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedQuestions.add({'id_question': questionId, 'points': 1});
                                } else {
                                  _selectedQuestions.removeWhere((q) => q['id_question'] == questionId);
                                }
                              });
                            },
                            secondary: _selectedQuestions.any((q) => q['id_question'] == questionId)
                                ? SizedBox(
                                    width: 60,
                                    child: TextField(
                                      decoration: const InputDecoration(labelText: "Điểm"),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final q = _selectedQuestions.firstWhere((q) => q['id_question'] == questionId);
                                        q['points'] = int.tryParse(value) ?? 1;
                                      },
                                    ),
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitQuiz,
                  child: const Text("Tạo bộ đề"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}