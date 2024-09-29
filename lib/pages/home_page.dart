import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:problem_solver/pages/question_page.dart';
import 'package:problem_solver/services/auth/auth_service.dart';
import 'package:problem_solver/services/question/question_service.dart';
import 'package:problem_solver/services/openai/openai_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  Future<void> createChatWithImage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final openAIService = OpenAIService();
      final questionService = QuestionService();

      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        print('No image selected');
        return;
      }

      final question = await openAIService.getPromptFromImageFile(image);
      if (question == null) {
        print('Failed to generate question from image');
        return;
      }

      final answer = await openAIService.getQuestionAnswer(question);
      if (answer == null) {
        print('Failed to get answer for the question');
        return;
      }

      final questionId =
          await questionService.createQuestions(question, answer);
      if (questionId == null) {
        print('Failed to create question ID');
        return;
      }
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arka plan gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst kısım (AppBar yerine özel bir widget)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: createChatWithImage,
                          icon: const Icon(Icons.add_a_photo),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: signOut,
                          icon: const Icon(Icons.logout),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Soru listesi
              Expanded(
                child: _buildQuestionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionList() {
    final String userID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('questions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "An error occurred",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No questions found",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildQuestionListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildQuestionListItem(DocumentSnapshot document) {
    Timestamp timestamp = document['timestamp'] as Timestamp;
    DateTime dateTime = timestamp.toDate();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionPage(questionId: document.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.question_answer,
              color: Colors.yellowAccent,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Question ID: ${document.id}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              "${dateTime.day}/${dateTime.month}/${dateTime.year}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
