import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:problem_solver/models/question.dart';

class QuestionService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createQuestions(
      String title, String question, String answer) async {
    try {
      final String userID = _firebaseAuth.currentUser!.uid;
      final Timestamp timestamp = Timestamp.now();

      Question newQuestion = Question(
        title: title,
        question: question,
        answer: answer,
        timestamp: timestamp,
      );

      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userID)
          .collection('questions')
          .add(newQuestion.toMap());

      return docRef.id;
    } catch (e) {
      print('Error creating question: $e');
      return null;
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    final String userID = _firebaseAuth.currentUser!.uid;

    try {
      await _firestore
          .collection('users')
          .doc(userID)
          .collection('questions')
          .doc(questionId)
          .delete();
    } catch (e) {
      print('Error deleting question: $e');
    }
  }

  Future<Question> getQuestion(String questionId) async {
    final String userID = _firebaseAuth.currentUser!.uid;

    DocumentSnapshot docSnapshot = await _firestore
        .collection('users')
        .doc(userID)
        .collection('questions')
        .doc(questionId)
        .get();

    return Question.fromMap(docSnapshot.data() as Map<String, dynamic>);
  }
}
