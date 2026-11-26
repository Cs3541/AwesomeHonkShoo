import 'package:awesome_honk_shoo_app/models/account_info.dart';
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _presenter.getCurrentUserEmail() ?? 'Unknown User';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
        title: const Row(
            children: [
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
        ),
      ),
      body: FutureBuilder<AccountInfo?>(
        future: _presenter.getAccountInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final info = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 50, color: Colors.white),

                ),
                const SizedBox(height: 24),
                _buildInfoCard(icon: Icons.person_outline, title: 'Name', 
                subtitle: info?.name.isNotEmpty == true ? info!.name : 'Not set'),
                _buildInfoCard(icon: Icons.email, title: 'Email', subtitle: email),
                _buildInfoCard(icon: Icons.cake_outlined, title: 'Birthday', 
                subtitle: info != null ? '${info.birthday.month}/${info.birthday.day}/${info.birthday.year}' : 'Not set'),
                _buildInfoCard(icon: Icons.bedtime_outlined, title: 'Bedtime',
                subtitle: info != null ? info.sleepStart.format(context) : 'Not set'),
                _buildInfoCard(icon: Icons.wb_sunny_outlined, title: 'Wake time',
                subtitle: info != null ? info.sleepEnd.format(context) : 'Not set'),
                const SizedBox(height: 28),
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
          );
        },
      ),
    );
  }
}