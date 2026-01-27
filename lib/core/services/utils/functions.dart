import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/model/doctor_list_response_model.dart';
import 'global_variables.dart';
import 'keys/shared_pref_keys.dart';

String getYearsOld(String dateTimeString) {
  final currentDate = DateTime.now();
  final parsedGivenDate = DateTime.parse(dateTimeString);
  final diff = currentDate.difference(parsedGivenDate).inDays ~/ 365;
  return diff.toString();
}

// String formatDate(String dateTimeString) {
//   DateTime dateTime = DateTime.parse(dateTimeString);
//   var formatter = DateFormat('dd MMMM yyyy hh:mm a');
//   String formattedDate = formatter.format(dateTime);
//   return formattedDate;
// }
//
// String formatDateDDMMMMYYYY(String dateTimeString) {
//   DateTime dateTime = DateTime.parse(dateTimeString);
//   var formatter = DateFormat('dd MMMM yyyy');
//   String formattedDate = formatter.format(dateTime);
//   return formattedDate;
// }

String formatDate(String dateTimeString) {
  var formatter = DateFormat('dd MMMM yyyy hh:mm a');

  // you have time in utc
  DateTime dateUtc = DateTime.parse(dateTimeString).toUtc();
  log("dateUtc: $dateUtc"); // 2019-10-10 12:05:01

  // convert it to local
  String formattedDate = formatter.format(dateUtc.toLocal());
  log("local: $formattedDate");

  return formattedDate;
}

String formatDateDDMMMMYYYY(String dateTimeString) {
  var formatter = DateFormat('dd MMMM yyyy');
  String formattedDate = "";
  try {
    // you have time in utc
    DateTime dateUtc = DateTime.parse(dateTimeString).toUtc();
    log("dateUtc: $dateUtc"); // 2019-10-10 12:05:01

    // convert it to local
    formattedDate = formatter.format(dateUtc.toLocal());
    log("local: $formattedDate");
  } catch (e) {}

  return formattedDate;
}

String? getShortAppointmentId({
  required String? appointmentId,
  required int wantedLength,
}) {
  if (appointmentId != null) {
    if (appointmentId.length >= wantedLength) {
      return appointmentId.substring(appointmentId.length - wantedLength);
    } else {
      return appointmentId;
    }
  }
  return null;
}

Future<String?> getCurrency() async {
  getCurrencySymbol = "৳";
  final prefs = await SharedPreferences.getInstance();
  String? countryName = await prefs.getString(getCountryName);
  if (countryName != null &&
      countryName.isNotEmpty &&
      countryName != "Bangladesh") {
    getCurrencySymbol = "\$";
  }
  return getCurrencySymbol;
}

Future<String?> getDoctorConsultationFee({required Doctor doctor}) async {
  String? consultationFee = "${doctor.consultationFee}";
  final prefs = await SharedPreferences.getInstance();
  String? countryName = await prefs.getString(getCountryName);
  log("country name from sf $countryName");
  if (countryName != null &&
      countryName.isNotEmpty &&
      countryName != "Bangladesh") {
    consultationFee = "${doctor.consultationFeeUsd}";
  }
  return consultationFee;
}

Future<String?> getDoctorFollowUpFeeUsd({required Doctor doctor}) async {
  String? followUpFeeUsd = "${doctor.followupFee}";
  final prefs = await SharedPreferences.getInstance();
  String? countryName = await prefs.getString(getCountryName);

  log("country name from sf $countryName");
  if (countryName != null &&
      countryName.isNotEmpty &&
      countryName != "Bangladesh") {
    followUpFeeUsd = "${doctor.followUpFeeUsd}";
  }
  return followUpFeeUsd;
}

Future<String?> getCountryID() async {
  http.Response data = await http.get(Uri.parse('http://ip-api.com/json'));
  Map<dynamic, dynamic> dataMap = jsonDecode(data.body);
  String country = dataMap['country'];
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(getCountryName, country);
  getCurrency();
  log("country code $country");
  log("country code ${dataMap.toString()}");
  return country;
}
