import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:problem_solver/firebase_options.dart';
import 'package:problem_solver/services/auth/auth_gate.dart';
import 'package:problem_solver/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Problem Solver',
      home: AuthGate(),
    );
  }
}
