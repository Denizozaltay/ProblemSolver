import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String question;
  final String answer;
  final Timestamp timestamp;

  Question({
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'timestamp': timestamp,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'],
      answer: map['answer'],
      timestamp: map['timestamp'],
    );
  }
}
