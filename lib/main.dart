import 'package:flutter/material.dart';
import 'dart:async';
import 'views/main_navigation.dart';

void main() {
  runApp(const HomeworkTrackerApp());
}

class HomeworkTrackerApp extends StatelessWidget {
  const HomeworkTrackerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class  SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen()
          ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Awesome Honk Shoo',
          style: TextStyle(
            fontSize: 28,
            color: const Color.fromARGB(255, 255, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}