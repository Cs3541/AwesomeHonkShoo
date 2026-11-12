import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _presenter = AuthPresenter();

  String? _errorMessage;

  void _handleLogin() async {
    final error = await _presenter.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      setState(() =>
        _errorMessage = error
      );
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email first.';
      });
      return;
    }

    final error = await _presenter.resetPassword(email);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151326),

      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF151326),
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Stack(
          children:[
            const Positioned(
              top: 10,
              left: 0,
              right: 200,
              child: Icon(
                Icons.star, color: Color.fromARGB(255, 255, 221, 0),
                size: 40
              ),
            ),

            const Positioned(
              top: 350,
              left: 300,
              right: 0,
              child: Icon(
                Icons.star, color: Color.fromARGB(255, 255, 221, 0),
                size: 40
              ),
            ),

            const Positioned(
              bottom: 200,
              left: 0,
              right: 250,
              child: Icon(
                Icons.star, color: Color.fromARGB(255, 255, 221, 0),
                size: 40
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),

                const SizedBox(height: 20),

                const Icon(
                  Icons.nightlight_round,
                  color: Color(0xFFB39DDB),
                  size: 120,
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFB39DDB),
                        width: 2,
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFB39DDB),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Login'),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                  ),
                ),
                TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ],
      )
    ),
      );
    }
  }