import 'package:awesome_honk_shoo_app/views/day_overview.dart';
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
  bool _isSleeping = false;

  void _onSleepStatusChanged(bool isSleeping) {
    setState(() {
      _isSleeping = isSleeping;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // widgets for the bottom tab. index matches the items in the below scaffold
    final List<Widget> _screens = [
      HomeScreen(isSleeping: _isSleeping, onSleepStatusChanged: _onSleepStatusChanged,
      ),
      const CalendarScreen(),
      DayOverviewScreen(),
    ];

    return Scaffold(
      // Keep tab state alive so the calendar retains its selected day.
      body: IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        backgroundColor: _isSleeping
          ? const Color(0xFF151326)
          : Colors.white,

        selectedItemColor: _isSleeping
            ? Colors.white
            : Colors.deepPurple,

        unselectedItemColor: _isSleeping
            ? Colors.white54
            : Colors.grey,

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
