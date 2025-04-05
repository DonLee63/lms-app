import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: const Text(
          'Khảo sát',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _surveyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue[800],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          if (!data['success']) {
            return Center(
              child: Text(
                data['message'],
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            );
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
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiêu đề: ${surveyData['title']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blue[900],
                        ),
                      ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   'Học phần ID: ${surveyData['hocphan_id']}',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      //   ),
                      // ),
                      if (surveyData['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Mô tả: ${surveyData['description']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Danh sách câu hỏi:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final questionId = question['question_id'] as int;
                      final questionType = question['type'] as String;

                      return FadeInUp(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          elevation: 6.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  isDarkMode ? Colors.grey[800]! : Colors.blue[50]!,
                                  isDarkMode ? Colors.grey[900]! : Colors.white,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Câu hỏi ${index + 1}: ${question['question']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (questionType == 'multiple_choice') ...[
                                    DropdownButton<String>(
                                      hint: Text(
                                        'Chọn điểm',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                      value: _answers[questionId],
                                      isExpanded: true,
                                      items: (question['options'] as List<dynamic>)
                                          .map((option) => DropdownMenuItem<String>(
                                                value: option.toString(),
                                                child: Text(
                                                  option.toString(),
                                                  style: TextStyle(
                                                    color: isDarkMode ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _answers[questionId] = value!;
                                        });
                                      },
                                      dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ] else if (questionType == 'text') ...[
                                    TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                        labelText: 'Nhập câu trả lời',
                                        labelStyle: TextStyle(
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black,
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ScaleTransitionButton(
                    onPressed: () async {
                      if (_answers.length != questions.length) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Vui lòng trả lời tất cả câu hỏi'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
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
                            SnackBar(
                              content: const Text('Gửi khảo sát thành công'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          );
                          ref.invalidate(studentSurveysProvider(widget.studentId));
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: ${result['message']}'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[600]!,
                            Colors.blue[800]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        'Gửi khảo sát',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ScaleTransitionButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _ScaleTransitionButtonState createState() => _ScaleTransitionButtonState();
}

class _ScaleTransitionButtonState extends State<ScaleTransitionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}