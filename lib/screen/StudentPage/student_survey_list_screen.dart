import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/survey_provider.dart';
import 'survey_screen.dart';

class StudentSurveyListScreen extends ConsumerWidget {
  final int studentId;

  const StudentSurveyListScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysAsync = ref.watch(studentSurveysProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Danh sách khảo sát'),
      ),
      body: surveysAsync.when(
        data: (data) {
          if (!data['success']) {
            return Center(child: Text(data['message']));
          }

          final surveys = (data['data'] as List<dynamic>)
              .map((survey) => survey as Map<String, dynamic>)
              .toList();

          if (surveys.isEmpty) {
            return const Center(child: Text('Không có khảo sát nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: surveys.length,
            itemBuilder: (context, index) {
              final survey = surveys[index];
              final hasSubmitted = survey['has_submitted'] as bool;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    survey['title'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Học phần: ${survey['hocphan_title']} (ID: ${survey['hocphan_id']})'),
                      const SizedBox(height: 4),
                      Text(
                        'Trạng thái: ${hasSubmitted ? 'Đã gửi' : 'Chưa gửi'}',
                        style: TextStyle(
                          color: hasSubmitted ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurveyScreen(
                          hocphanId: survey['hocphan_id'] as int,
                          studentId: studentId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}