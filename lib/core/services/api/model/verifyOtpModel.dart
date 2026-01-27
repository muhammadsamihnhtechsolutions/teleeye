import 'dart:convert';

import '../../utils/keys/token_keys.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class VerifyOtpModel {
  String traceId;
  String code;
  VerifyOtpModel({required this.traceId, required this.code});

  Map<String, dynamic> toMap() {
    final deviceToken =
        userDeviceToken.trim().isNotEmpty
            ? userDeviceToken.trim()
            : pushNotificationTokenKey.trim();
    final map = <String, dynamic>{
      'traceId': traceId,
      'code': code,
      // "deviceToken": pushNotificationTokenKey,
      "deviceToken": deviceToken,
    };
    if (voipDeviceToken.trim().isNotEmpty) {
      map['voipToken'] = voipDeviceToken.trim();
    }
    print("VerifyOtpModel.toMap: deviceToken = $deviceToken");
    return map;
  }

  factory VerifyOtpModel.fromMap(Map<String, dynamic> map) {
    return VerifyOtpModel(
      traceId: map['traceId'] as String,
      code: map['code'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory VerifyOtpModel.fromJson(String source) =>
      VerifyOtpModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'VerifyOtpModel(traceId: $traceId, code: $code)';
}

class VerifyOtpApiResponseData {
  String? token;
  bool? isNewUser;
  VerifyOtpApiResponseData({this.token, this.isNewUser});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'token': token};
  }

  factory VerifyOtpApiResponseData.fromMap(Map<String, dynamic> map) {
    String? parsedToken;
    final tokenCandidate = map['token'];
    if (tokenCandidate is String && tokenCandidate.trim().isNotEmpty) {
      parsedToken = tokenCandidate;
    } else {
      final accessTokenCandidate =
          map['accessToken'] ?? map['access_token'] ?? map['jwt'];
      if (accessTokenCandidate is String &&
          accessTokenCandidate.trim().isNotEmpty) {
        parsedToken = accessTokenCandidate;
      }
    }

    bool? parsedIsNewUser;
    final patient = map['patient'];
    if (patient is Map<String, dynamic>) {
      parsedIsNewUser = patient['name'] == null;
    }

    return VerifyOtpApiResponseData(
      token: parsedToken,
      isNewUser: parsedIsNewUser,
    );
  }

  String toJson() => json.encode(toMap());

  factory VerifyOtpApiResponseData.fromJson(String source) =>
      VerifyOtpApiResponseData.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() => 'VerifyOtpApiResponseData(token: $token)';
}

class VerifyOtpApiResponse {
  String? status;
  VerifyOtpApiResponseData? data;
  String? message;
  VerifyOtpApiResponse({this.status, this.message, this.data});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'status': status, 'message': message};
  }

  factory VerifyOtpApiResponse.fromMap(Map<String, dynamic> map) {
    final dynamic rawData = map['data'];
    Map<String, dynamic>? dataMap;
    if (rawData is Map<String, dynamic>) {
      dataMap = rawData;
    } else {
      dataMap = null;
    }

    // Some backends return token fields at the top-level rather than inside
    // `data`. Normalize into `data` so login flow doesn't get stuck on OTP.
    final topLevelToken = map['token'] ?? map['accessToken'] ?? map['access_token'];
    if (dataMap == null &&
        topLevelToken is String &&
        topLevelToken.trim().isNotEmpty) {
      dataMap = {'token': topLevelToken};
    }

    return VerifyOtpApiResponse(
      status: map['status'] != null ? map['status'] as String : null,
      message: map['message'] != null ? map['message'] as String : null,
      data: dataMap != null ? VerifyOtpApiResponseData.fromMap(dataMap) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory VerifyOtpApiResponse.fromJson(String source) =>
      VerifyOtpApiResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}
