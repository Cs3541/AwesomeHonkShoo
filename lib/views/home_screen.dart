import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'caffeine_log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSleeping = false;

  void _toggleSleepStatus() {
    setState(() {
      _isSleeping = !_isSleeping;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Current Sleep Status:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _isSleeping ? 'Sleeping' : 'Awake',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _isSleeping ? const Color.fromARGB(255, 33, 40, 243) : Colors.orange,
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _toggleSleepStatus,
              child: Text(
                _isSleeping ? 'Wake Up' : 'Go to Sleep',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CaffeineLogScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.local_cafe),
              label: const Text('Create Log / Caffeine'),
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