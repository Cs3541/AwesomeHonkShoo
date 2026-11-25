import 'package:cloud_firestore/cloud_firestore.dart';
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

  Map<String, dynamic> toMap(){
    return  {
      'name': name,
      'birthday': Timestamp.fromDate(birthday),
      'sleepStart': '${sleepStart.hour.toString().padLeft(2, '0')}:${sleepStart.minute.toString().padLeft(2, '0')}',
      'sleepEnd': '${sleepEnd.hour.toString().padLeft(2, '0')}:${sleepEnd.minute.toString().padLeft(2, '0')}',
    };
  }
}

