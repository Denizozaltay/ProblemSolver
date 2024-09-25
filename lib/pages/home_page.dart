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
        print('Resim seçilmedi');
        return;
      }

      final question = await openAIService.getPromptFromImageFile(image);
      if (question == null) {
        print('Resimden soru oluşturulamadı');
        return;
      }

      final answer = await openAIService.getQuestionAnswer(question);
      if (answer == null) {
        print('Soru için cevap alınamadı');
        return;
      }

      final questionId =
          await questionService.createQuestions(question, answer);
      if (questionId == null) {
        print('Soru ID\'si oluşturulamadı');
        return;
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
              onPressed: createChatWithImage, icon: const Icon(Icons.add)),
        ],
      ),
      body: _buildQuestionList(),
    );
  }

  Widget _buildQuestionList() {
    final String userID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('questions')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Bir hata oluştu");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Yükleniyor...");
        }

        return ListView(
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

    return ListTile(
      title: Text(document.id),
      subtitle: Text(dateTime.toString()),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionPage(questionId: document.id),
          ),
        );
      },
    );
  }
}
