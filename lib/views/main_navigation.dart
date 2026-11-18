import 'package:awesome_honk_shoo_app/views/day_overview.dart';
import 'package:awesome_honk_shoo_app/views/profile_screen.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'calendar_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // widgets for the bottom tab. index matches the items in the below scaffold
  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    DayOverviewScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.nightlight_round_outlined),
            label: '(test tab) Day Overview',
          ),
        ],
      ),
    );
  }
}
