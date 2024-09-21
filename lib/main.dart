import 'package:flutter/material.dart';
import 'package:problem_solver/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Problem Solver',
      home: HomePage(),
    );
  }
}
