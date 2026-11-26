import 'package:flutter/material.dart';
import '../models/account_info.dart';
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
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
        title: Row(
            children: [
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
        )
      ),
      body: FutureBuilder<AccountInfo?>(
        future: _presenter.getAccountInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child:CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final info = snapshot.data;
          if (info == null) {
            return const Center(child: Text('No account info found.'));
        }
        return ListView(padding: const EdgeInsets.all(16),
        children: [
          Text('Name: ${info.name}'),
          Text('Birthday: ${info.birthday.month}/${info.birthday.day}/${info.birthday.year}'),
          Text('Bedtime: ${info.sleepStart.format(context)}'),
          Text('Wake time: ${info.sleepEnd.format(context)}'),
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
        );
  }),
      
    );
  }
}