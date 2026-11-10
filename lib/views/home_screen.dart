import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
        width: double.infinity,
        color: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: const Row(
          children: [
            Icon(Icons.campaign, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Special offer available now!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
            const Text(
              'Welcome to the Awesome Honk Shoo App!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Get Started'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}