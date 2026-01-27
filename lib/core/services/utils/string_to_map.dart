import 'dart:convert';
import 'package:flutter/foundation.dart';

Map<String, dynamic> stringToMap(String inputString) {
  try {
    Map<String, dynamic> jsonMap = jsonDecode(inputString);
    return jsonMap;
  } catch (e) {
    print("Invalid JSON string");
    return {};
  }
}

Future<Map<String, dynamic>> stringToMapAsync(String inputString) async {
  try {
    return await compute(_decodeJsonToMap, inputString);
  } catch (_) {
    return <String, dynamic>{};
  }
}

Map<String, dynamic> _decodeJsonToMap(String inputString) {
  try {
    final dynamic decoded = jsonDecode(inputString);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
}
