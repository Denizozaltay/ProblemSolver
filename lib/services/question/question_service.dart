import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:problem_solver/models/question.dart';

class QuestionService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createQuestions(String question, String answer) async {
    try {
      final String userID = _firebaseAuth.currentUser!.uid;
      final Timestamp timestamp = Timestamp.now();

      Question newQuestion = Question(
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
      print('Soru oluşturulurken hata oluştu: $e');
      return null;
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
