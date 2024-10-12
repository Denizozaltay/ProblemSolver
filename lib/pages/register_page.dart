import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:problem_solver/components/my_button.dart';
import 'package:problem_solver/components/my_text_field.dart';
import 'package:problem_solver/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    final username = usernameController.text.trim();
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,15}$');

    if (!usernameRegExp.hasMatch(username)) {
      _showSnackBar(
        "Invalid username. Usernames can only contain letters, numbers, and underscores, and be between 3 and 15 characters.",
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailAndPassword(
        username,
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        SizedBox(height: 30),
        Text(
          'Problem Solver',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 20),
        Icon(
          Icons.lightbulb_outline,
          size: 100,
          color: Colors.yellowAccent,
        ),
        SizedBox(height: 30),
        Text(
          "Let's create an account for you!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        MyTextField(
          controller: usernameController,
          hintText: "Username",
          obscureText: false,
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: emailController,
          hintText: "Email",
          obscureText: false,
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: passwordController,
          hintText: "Password",
          obscureText: true,
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: confirmPasswordController,
          hintText: "Confirm Password",
          obscureText: true,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return MyButton(onTap: _signUp, text: "Sign Up");
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account?",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: widget.onTap,
              child: const Text(
                "Login now",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBody() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildInputFields(),
            _buildSignUpButton(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}
