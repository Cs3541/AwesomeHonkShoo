import 'package:flutter/material.dart';

class AccountInfo {
  final String name;
  final DateTime birthday;
  final TimeOfDay sleepStart; // bedtime
  final TimeOfDay sleepEnd;   // wake time

  const AccountInfo({
    required this.name,
    required this.birthday,
    required this.sleepStart,
    required this.sleepEnd,
  });
}

