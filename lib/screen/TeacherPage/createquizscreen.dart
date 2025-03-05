import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/trac_nghiem_question.dart';
import '../../providers/exercise_provider.dart';

// Trang tạo đề thi
class CreateQuizScreen extends ConsumerStatefulWidget {
  final int hocphanId;

  const CreateQuizScreen({super.key, required this.hocphanId});

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _totalPointsController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  List<Map<String, dynamic>> _selectedQuestions = [];
  int _userId = 1; // Giá trị mặc định, sẽ được cập nhật trong initState
  late Future<List<TracNghiemCauhoi>> _questionsFuture = _loadQuestions(); // Khởi tạo ngay

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
      _questionsFuture = ref.read(exerciseRepositoryProvider).getQuestionsByHocphan(widget.hocphanId, _userId);
    });
  }

  Future<List<TracNghiemCauhoi>> _loadQuestions() async {
    // Giá trị khởi tạo mặc định, sẽ được cập nhật trong _loadUserId
    return ref.read(exerciseRepositoryProvider).getQuestionsByHocphan(widget.hocphanId, _userId);
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
      final quiz = BodeTracNghiem(
        title: _titleController.text,
        hocphanId: widget.hocphanId,
        slug: "${_titleController.text.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}",
        startTime: _startTime!,
        endTime: _endTime!,
        time: int.parse(_timeController.text),
        totalPoints: int.parse(_totalPointsController.text),
        questions: _selectedQuestions,
        userId: _userId,
      );

      try {
        final createdQuiz = await ref.read(createQuizProvider(quiz).future);
        if (createdQuiz != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tạo đề thi thành công!")),
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
      appBar: AppBar(title: const Text("Tạo đề thi trắc nghiệm")),
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
                  decoration: const InputDecoration(labelText: "Tiêu đề đề thi"),
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
                  child: FutureBuilder<List<TracNghiemCauhoi>>(
                    future: _questionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Lỗi: ${snapshot.error}"));
                      }
                      final questions = snapshot.data ?? [];
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return CheckboxListTile(
                            title: Text(question.content),
                            subtitle: Text("ID: ${question.id}"),
                            value: _selectedQuestions.any((q) => q['id_question'] == question.id),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedQuestions.add({'id_question': question.id, 'points': 0});
                                } else {
                                  _selectedQuestions.removeWhere((q) => q['id_question'] == question.id);
                                }
                              });
                            },
                            secondary: _selectedQuestions.any((q) => q['id_question'] == question.id)
                                ? SizedBox(
                                    width: 60,
                                    child: TextField(
                                      decoration: const InputDecoration(labelText: "Điểm"),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final q = _selectedQuestions.firstWhere((q) => q['id_question'] == question.id);
                                        q['points'] = int.tryParse(value) ?? 0;
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
                  child: const Text("Tạo đề thi"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}