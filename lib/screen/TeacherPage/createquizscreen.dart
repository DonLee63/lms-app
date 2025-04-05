import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/trac_nghiem_question.dart';
import '../../providers/exercise_provider.dart';

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
  int _userId = 1;
  late Future<List<TracNghiemCauhoi>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    // Khởi tạo _questionsFuture với giá trị mặc định (có thể là rỗng)
    _questionsFuture = Future.value([]);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
      // Cập nhật _questionsFuture sau khi có userId
      _questionsFuture = ref.read(exerciseRepositoryProvider).getQuestionsByHocphan(widget.hocphanId, _userId);
    });
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
        setState(() {
          if (isStart) _startTime = selectedDateTime;
          else _endTime = selectedDateTime;
        });
      }
    }
  }

  Future<void> _submitQuiz() async {
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
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text("Tạo đề thi thành công!"), backgroundColor: Colors.green[700]),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red[700]),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin và chọn ít nhất 1 câu hỏi"), backgroundColor: Colors.red),
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
              Navigator.pop(context); // Đóng dialog

              try {
                // Gọi provider để xóa câu hỏi
                await ref.read(deleteQuestionProvider(questionId).future);

                // Hiển thị thông báo thành công
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

                // Làm mới danh sách câu hỏi
                _refreshQuestions();
              } catch (e) {
                // Hiển thị thông báo lỗi
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 4.0,
        title: const Text(
          'Tạo đề thi trắc nghiệm',
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
                            validator: (value) => value!.isEmpty ? "Vui lòng nhập tiêu đề" : null,
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
                                  validator: (value) => value!.isEmpty ? "Vui lòng nhập thời gian" : null,
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
                                  validator: (value) => value!.isEmpty ? "Vui lòng nhập tổng điểm" : null,
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
                          final isSelected = _selectedQuestions.any((q) => q['id_question'] == question.id);
                          return FadeInUp(
                            duration: Duration(milliseconds: 500 + (index * 100)),
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: isDarkMode ? Colors.grey[850] : Colors.white,
                              child: CheckboxListTile(
                                title: Text(
                                  question.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.white : Colors.grey[800],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  "ID: ${question.id}",
                                  style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                ),
                                value: isSelected,
                                activeColor: Colors.green[700],
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedQuestions.add({'id_question': question.id, 'points': 0});
                                    } else {
                                      _selectedQuestions.removeWhere((q) => q['id_question'] == question.id);
                                    }
                                  });
                                },
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
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            final q = _selectedQuestions.firstWhere((q) => q['id_question'] == question.id);
                                            q['points'] = int.tryParse(value) ?? 0;
                                          },
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        if (question.id != null) {
                                          _deleteQuestion(context, question.id!);
                                        }
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
                  label: const Text("Tạo đề thi"),
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
    );
  }
}