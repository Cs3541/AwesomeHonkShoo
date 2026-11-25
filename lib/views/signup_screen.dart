import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import 'login_screen.dart';
import '../models/account_info.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _presenter = AuthPresenter();

  String? _errorMessage;

  void _handleSignup() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() =>
        _errorMessage = 'Passwords do not match.');
      return;
    }

    final info = await _showAccountInfoDialog();
    if (info == null || !mounted) return;

    final error = await _presenter.signUp(
      _emailController.text.trim(),
      password,
      info,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
        final navigator = Navigator.of(context);
        navigator.popUntil((route) => route.isFirst);
    }
  }

Future<AccountInfo?> _showAccountInfoDialog() {
  DateTime? birthday;
  TimeOfDay? sleepStart;
  TimeOfDay? sleepEnd;
  final nameController = TextEditingController();

  return showDialog<AccountInfo>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      // StatefulBuilder lets the dialog rebuild when a picker returns
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final ready =
              birthday != null && sleepStart != null && sleepEnd != null;

          return AlertDialog(
            title: const Text('A little more about you'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText:"Name"),
                  onChanged: (_) => setDialogState(() {}),
                ),
                ListTile(
                  title: const Text('Birthday'),
                  subtitle: Text(birthday == null
                      ? 'Tap to pick'
                      : '${birthday!.month}/${birthday!.day}/${birthday!.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialogState(() => birthday = picked);
                  },
                ),
                ListTile(
                  title: const Text('Bedtime'),
                  subtitle: Text(sleepStart == null
                      ? 'Tap to pick'
                      : sleepStart!.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 22, minute: 0),
                    );
                    if (picked != null) setDialogState(() => sleepStart = picked);
                  },
                ),
                ListTile(
                  title: const Text('Wake time'),
                  subtitle: Text(sleepEnd == null
                      ? 'Tap to pick'
                      : sleepEnd!.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 7, minute: 0),
                    );
                    if (picked != null) setDialogState(() => sleepEnd = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                // null onPressed greys the button out until everything is filled in
                onPressed: ready
                    ? () => Navigator.pop(
                          dialogContext,
                          AccountInfo(
                            name: nameController.text.trim(),
                            birthday: birthday!,
                            sleepStart: sleepStart!,
                            sleepEnd: sleepEnd!,
                          ),
                        )
                    : null,
                child: const Text('Finish'),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
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

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),

            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _handleSignup,
              child: const Text('Sign Up'),
            ),

            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              child: const Text(
                'Already have an account? Log In',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
