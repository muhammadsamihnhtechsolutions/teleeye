import 'dart:developer';

import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/keys/token_keys.dart';

Future<void> saveToken({required String token}) async {
  patientToken = token;
  log('UserToken: $token');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(userTokenKey, token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(userTokenKey);
  if (token != null) {
    log('UserToken: $token');
    patientToken = token;
  }
  return token;
}

Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(userTokenKey);
}
