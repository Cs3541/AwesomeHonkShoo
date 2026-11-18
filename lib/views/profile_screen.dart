import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';

class ProfileScreen extends StatelessWidget {
  final AuthPresenter _presenter = AuthPresenter();

  ProfileScreen({super.key});

  void _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await _presenter.logout();
    navigator.popUntil((route) => route.isFirst);
  }


  @override
  Widget build(BuildContext context) {
    final email = _presenter.getCurrentUserEmail() ?? 'Unknown User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child:ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(email),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}