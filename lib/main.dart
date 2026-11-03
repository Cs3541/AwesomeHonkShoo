import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/browser.dart';
import 'package:timezone/data/latest.dart';
import 'views/main_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initNotifications();
  runApp(const AwesomeHonkShooApp());
}

Future<void> initNotifications() async {
  initializeTimeZones();
  setLocalLocation(
    getLocation('America/Toronto'),
  );

  const InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings('mipmap/launcher_icon')
    );
  await notificationsPlugin.initialize(initializationSettings);
}

class AwesomeHonkShooApp extends StatelessWidget {
  const AwesomeHonkShooApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome Honk Shoo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class  SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder:(context, snapshot){
        if (snapshot.connectionState== ConnectionState.waiting){
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

        if (snapshot.hasData){
          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}