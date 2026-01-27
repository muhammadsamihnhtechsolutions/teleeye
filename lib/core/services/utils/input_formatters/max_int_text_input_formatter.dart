import 'package:flutter/services.dart';

class MaxIntTextInputFormatter extends TextInputFormatter {
  const MaxIntTextInputFormatter({required this.max});

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();
    if (text.isEmpty) return newValue;

    final value = int.tryParse(text);
    if (value == null) return oldValue;

    if (value > max) return oldValue;

    return newValue;
  }
}
