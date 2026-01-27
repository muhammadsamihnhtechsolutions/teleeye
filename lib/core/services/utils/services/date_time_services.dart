import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTimeOfDay(TimeOfDay timeOfDay) {
  // Convert TimeOfDay to DateTime
  final now = DateTime.now();
  final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);

  // Format the time using the intl package
  final timeFormat = DateFormat.jm();

  // Format the time and return it as a string
  return timeFormat.format(dateTime);
}
