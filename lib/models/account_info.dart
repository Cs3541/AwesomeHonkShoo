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

  factory AccountInfo.fromMap(Map<String, dynamic> map) {
    final birthdayTs = map['birthday'] as Timestamp?;
    final startParts = (map['sleepStart'] as String? ?? '22:00').split(':');
    final endParts = (map['sleepEnd'] as String? ?? '07:00').split(':');

    return AccountInfo(name: map['name'] as String? ?? '', birthday: birthdayTs?.toDate() ?? DateTime(2000), 
    sleepStart: TimeOfDay(hour: int.tryParse(startParts[0]) ?? 22, minute: int.tryParse(startParts[1]) ?? 0), 
    sleepEnd: TimeOfDay(hour: int.tryParse(endParts[0]) ?? 7, minute: int.tryParse(endParts[1]) ?? 0));
  }
}

