import 'package:flutter/material.dart';
import 'package:problem_solver/services/question/question_service.dart';

class QuestionPage extends StatefulWidget {
  final String questionId;
  const QuestionPage({super.key, required this.questionId});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final QuestionService _questionService = QuestionService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.questionId),
        ),
        body: Column(
          children: [Expanded(child: _buildQuestionInfo())],
        ));
  }

  Widget _buildQuestionInfo() {
    return FutureBuilder(
      future: _questionService.getQuestion(widget.questionId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            return const Center(child: Text('Hata oluştu'));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.data.question,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.data.answer,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}
