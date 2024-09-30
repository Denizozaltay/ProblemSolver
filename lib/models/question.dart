import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String title;
  final String question;
  final String answer;
  final Timestamp timestamp;

  Question({
    required this.title,
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'question': question,
      'answer': answer,
      'timestamp': timestamp,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      title: map['title'],
      question: map['question'],
      answer: map['answer'],
      timestamp: map['timestamp'],
    );
  }
}
