import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/survey_provider.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  final int hocphanId;
  final int studentId;

  const SurveyScreen({
    super.key,
    required this.hocphanId,
    required this.studentId,
  });

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  Map<int, String> _answers = {};
  late Future<Map<String, dynamic>> _surveyFuture;

  @override
  void initState() {
    super.initState();
    _surveyFuture = ref.read(surveyProvider({
      'hocphanId': widget.hocphanId,
      'studentId': widget.studentId,
    }).future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Khảo sát'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _surveyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          if (!data['success']) {
            return Center(child: Text(data['message']));
          }

          final surveyData = data['data'];
          final questions = (surveyData['questions'] as List<dynamic>)
              .map((q) => q as Map<String, dynamic>)
              .toList();
          final hasSubmitted = surveyData['has_submitted'] as bool;

          if (hasSubmitted) {
            return const Center(
              child: Text(
                'Bạn đã gửi khảo sát này rồi!',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiêu đề: ${surveyData['title']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Học phần ID: ${surveyData['hocphan_id']}'),
                if (surveyData['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text('Mô tả: ${surveyData['description']}'),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Danh sách câu hỏi:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final questionId = question['question_id'] as int;
                      final questionType = question['type'] as String;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Câu hỏi ${index + 1}: ${question['question']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (questionType == 'multiple_choice') ...[
                                DropdownButton<String>(
                                  hint: const Text('Chọn điểm'),
                                  value: _answers[questionId],
                                  isExpanded: true,
                                  items: (question['options'] as List<dynamic>)
                                      .map((option) => DropdownMenuItem<String>(
                                            value: option.toString(),
                                            child: Text(option.toString()),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _answers[questionId] = value!;
                                    });
                                  },
                                ),
                              ] else if (questionType == 'text') ...[
                                TextField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Nhập câu trả lời',
                                  ),
                                  maxLines: 3,
                                  onChanged: (value) {
                                    _answers[questionId] = value;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_answers.length != questions.length) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng trả lời tất cả câu hỏi')),
                        );
                        return;
                      }

                      final answers = _answers.entries
                          .map((entry) => {
                                'question_id': entry.key,
                                'answer': entry.value,
                              })
                          .toList();

                      try {
                        final result = await ref.read(submitSurveyProvider({
                          'hocphanId': widget.hocphanId,
                          'studentId': widget.studentId,
                          'answers': answers,
                        }).future);

                        if (result['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gửi khảo sát thành công')),
                          );
                          // Làm mới studentSurveysProvider để cập nhật trạng thái has_submitted
                          ref.invalidate(studentSurveysProvider(widget.studentId));
                          // Điều hướng về màn hình trước đó
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${result['message']}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: $e')),
                        );
                      }
                    },
                    child: const Text('Gửi khảo sát'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}