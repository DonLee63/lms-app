import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/trac_nghiem_question.dart';
import '../../providers/exercise_provider.dart';

class EditQuizScreen extends ConsumerStatefulWidget {
  final int quizId;
  final int hocphanId;

  const EditQuizScreen({
    super.key,
    required this.quizId,
    required this.hocphanId,
  });

  @override
  ConsumerState<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends ConsumerState<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _totalPointsController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  List<Map<String, int>> _selectedQuestions = [];
  int _userId = 1;
  late Future<List<TracNghiemCauhoi>> _questionsFuture;
  late Future<BodeTracNghiem> _quizFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = Future.value([]);
    _quizFuture = ref.read(exerciseRepositoryProvider).getQuizById(widget.quizId);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
      _questionsFuture = ref.read(exerciseRepositoryProvider).getQuestionsByHocphan(widget.hocphanId, _userId);
    });
    await _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final quiz = await _quizFuture;
      setState(() {
        _titleController.text = quiz.title;
        _timeController.text = quiz.time.toString();
        _totalPointsController.text = quiz.totalPoints.toString();
        _startTime = quiz.startTime.toLocal();
        _endTime = quiz.endTime.toLocal();
        _selectedQuestions = quiz.questions
            .map((q) => <String, int>{
                  'id_question': q['id_question'] as int,
                  'points': q['points'] as int,
                })
            .toList();
        debugPrint('Loaded quiz: startTime=$_startTime, endTime=$_endTime');
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải dữ liệu đề thi: $e"), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  Future<void> _refreshQuestions() async {
    setState(() {
      _questionsFuture = ref.read(exerciseRepositoryProvider).getQuestionsByHocphan(widget.hocphanId, _userId);
    });
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
        debugPrint('Selected local time: $selectedDateTime');
        setState(() {
          if (isStart) {
            _startTime = selectedDateTime;
          } else {
            _endTime = selectedDateTime;
          }
        });
      }
    }
  }

  Future<void> _submitQuiz() async {
    final totalPoints = int.tryParse(_totalPointsController.text) ?? 0;
    final questionPointsSum = _selectedQuestions.fold<int>(0, (sum, q) => sum + (q['points'] ?? 0));

    if (_formKey.currentState!.validate() &&
        _startTime != null &&
        _endTime != null &&
        _selectedQuestions.isNotEmpty &&
        totalPoints == questionPointsSum) {
      final quiz = BodeTracNghiem(
        id: widget.quizId,
        title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
        hocphanId: widget.hocphanId,
        slug: "${(_titleController.text.isEmpty ? 'untitled' : _titleController.text).toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}",
        startTime: _startTime!,
        endTime: _endTime!,
        time: int.tryParse(_timeController.text) ?? 60,
        totalPoints: totalPoints,
        questions: _selectedQuestions.map((q) => q.cast<String, dynamic>()).toList(),
        userId: _userId,
      );

      try {
        debugPrint('Submitting quiz: local startTime=${quiz.startTime}, endTime=${quiz.endTime}');
        final updatedQuiz = await ref.read(updateQuizProvider(quiz).future);
        debugPrint('API response: ${jsonEncode(updatedQuiz.toJson())}');
        if (updatedQuiz.startTime != quiz.startTime) {
          debugPrint('Time mismatch: sent=${quiz.startTime}, received=${updatedQuiz.startTime}');
        }
        setState(() {
          _quizFuture = ref.read(exerciseRepositoryProvider).getQuizById(widget.quizId);
        });
        ref.invalidate(exerciseRepositoryProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text("Cập nhật đề thi thành công!"), backgroundColor: Colors.green[700]),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Submit error: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red[700]),
          );
        }
      }
    } else {
      String errorMessage = "Vui lòng điền đầy đủ thông tin và chọn ít nhất 1 câu hỏi";
      if (totalPoints != questionPointsSum) {
        errorMessage = "Tổng điểm câu hỏi ($questionPointsSum) không khớp với tổng điểm đề thi ($totalPoints)";
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  Future<void> _deleteQuestion(BuildContext context, int questionId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa câu hỏi này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(deleteQuestionProvider(questionId).future);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa câu hỏi trắc nghiệm thành công'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    ),
                  );
                }
                _refreshQuestions();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16.0),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Sửa đề thi trắc nghiệm',
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
      body: FutureBuilder<BodeTracNghiem>(
        future: _quizFuture,
        builder: (context, quizSnapshot) {
          if (quizSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),
            );
          }
          if (quizSnapshot.hasError) {
            return Center(
              child: Text("Lỗi tải đề thi: ${quizSnapshot.error}", style: TextStyle(color: Colors.red[700])),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
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
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Tiêu đề đề thi',
                                  prefixIcon: Icon(Icons.quiz, color: Colors.blue[700]),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                ),
                                validator: (value) => (value == null || value.isEmpty) ? "Vui lòng nhập tiêu đề" : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _timeController,
                                      decoration: InputDecoration(
                                        labelText: 'Thời gian (phút)',
                                        prefixIcon: Icon(Icons.timer, color: Colors.blue[700]),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) =>
                                          (value == null || value.isEmpty) ? "Vui lòng nhập thời gian" : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _totalPointsController,
                                      decoration: InputDecoration(
                                        labelText: 'Tổng điểm',
                                        prefixIcon: Icon(Icons.score, color: Colors.blue[700]),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) =>
                                          (value == null || value.isEmpty) ? "Vui lòng nhập tổng điểm" : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _startTime != null
                                          ? "Bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm').format(_startTime!)}"
                                          : "Chọn thời gian bắt đầu",
                                      style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _selectDateTime(context, true),
                                    icon: const Icon(Icons.calendar_today, size: 18),
                                    label: const Text("Chọn"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _endTime != null
                                          ? "Kết thúc: ${DateFormat('dd/MM/yyyy HH:mm').format(_endTime!)}"
                                          : "Chọn thời gian kết thúc",
                                      style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _selectDateTime(context, false),
                                    icon: const Icon(Icons.event_busy, size: 18),
                                    label: const Text("Chọn"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chọn câu hỏi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 300,
                      child: FutureBuilder<List<TracNghiemCauhoi>>(
                        future: _questionsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Lỗi: ${snapshot.error}", style: TextStyle(color: Colors.red[700])),
                            );
                          }
                          final questions = snapshot.data ?? [];
                          if (questions.isEmpty) {
                            return Center(
                              child: Text(
                                "Chưa có câu hỏi nào",
                                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              final question = questions[index];
                              final isSelected =
                                  _selectedQuestions.any((q) => q['id_question'] == (question.id ?? 0));
                              return FadeInUp(
                                duration: Duration(milliseconds: 500 + (index * 100)),
                                child: Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                                  child: CheckboxListTile(
                                    title: Text(
                                      question.content.isNotEmpty ? question.content : 'No content',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode ? Colors.white : Colors.grey[800],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      "ID: ${question.id ?? 'N/A'}",
                                      style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                    ),
                                    value: isSelected,
                                    activeColor: Colors.green[700],
                                    onChanged: question.id != null
                                        ? (value) {
                                            setState(() {
                                              if (value == true) {
                                                if (!_selectedQuestions
                                                    .any((q) => q['id_question'] == question.id)) {
                                                  _selectedQuestions
                                                      .add({'id_question': question.id!, 'points': 0});
                                                }
                                              } else {
                                                _selectedQuestions
                                                    .removeWhere((q) => q['id_question'] == question.id);
                                              }
                                            });
                                          }
                                        : null,
                                    secondary: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected)
                                          SizedBox(
                                            width: 80,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: "Điểm",
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                              ),
                                              keyboardType: TextInputType.number,
                                              controller: TextEditingController(
                                                text: _selectedQuestions
                                                    .firstWhere(
                                                      (q) => q['id_question'] == (question.id ?? 0),
                                                      orElse: () => <String, int>{'id_question': 0, 'points': 0},
                                                    )['points']
                                                    .toString(),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  final q = _selectedQuestions.firstWhere(
                                                    (q) => q['id_question'] == (question.id ?? 0),
                                                    orElse: () =>
                                                        <String, int>{'id_question': question.id ?? 0, 'points': 0},
                                                  );
                                                  q['points'] = int.tryParse(value) ?? 0;
                                                  if (!_selectedQuestions.contains(q)) {
                                                    _selectedQuestions.add(q);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        if (question.id != null)
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              _deleteQuestion(context, question.id!);
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _submitQuiz,
                      icon: const Icon(Icons.save),
                      label: const Text("Cập nhật đề thi"),
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
          );
        },
      ),
    );
  }
}