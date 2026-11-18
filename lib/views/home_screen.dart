import 'package:awesome_honk_shoo_app/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_honk_shoo_app/views/caffeine_log_screen.dart';
import 'package:awesome_honk_shoo_app/views/profile_screen.dart';

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
      backgroundColor: _isSleeping ? const Color(0xFF151326) : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          backgroundColor:
            _isSleeping
                  ? const Color(0xFF1A1930) : Colors.blueAccent,
          automaticallyImplyLeading: false, // Removes default back button
          title: Row(
            children: [
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Awesome HonkShoo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.account_circle), color: Colors.white,
              )
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Sleep Status:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isSleeping ? Colors.white : Colors.black,
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

            if (!_isSleeping)
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
          ],
        ),
      ),
    );
  }
}
