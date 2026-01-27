import 'dart:ui';

enum Language {
  english(
    Locale('en', 'US'),
  ),
  bangla(
    Locale('bn', 'BD'),
  );

  /// Add another languages support here
  const Language(
    this.value,
  );

  final Locale value;
}
