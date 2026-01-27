import 'dart:convert';

import '../../utils/keys/token_keys.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class LoginModel {
  String dialCode;
  String phone;
  LoginModel({required this.dialCode, required this.phone});

  @override
  String toString() => 'LoginModel(dialCode: $dialCode, phone: $phone)';

  Map<String, dynamic> toMap() {
    final deviceToken =
        userDeviceToken.trim().isNotEmpty
            ? userDeviceToken.trim()
            : pushNotificationTokenKey.trim();
    final map = <String, dynamic>{
      'dialCode': dialCode,
      'phone': phone,
      // 'deviceToken': pushNotificationTokenKey,
      "deviceToken": deviceToken,
    };
    if (voipDeviceToken.trim().isNotEmpty) {
      map['voipToken'] = voipDeviceToken.trim();
    }
    print("LoginModel.toMap: deviceToken = $deviceToken");
    return map;
  }

  factory LoginModel.fromMap(Map<String, dynamic> map) {
    return LoginModel(
      dialCode: map['dialCode'] as String,
      phone: map['phone'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginModel.fromJson(String source) =>
      LoginModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class LoginApiResponseModel {
  String? status;
  String? message;
  LoginApiResponseDataModel? data;
  LoginApiResponseModel({this.status, this.message, this.data});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'message': message,
      'data': data?.toMap(),
    };
  }

  factory LoginApiResponseModel.fromMap(Map<String, dynamic> map) {
    final dynamic rawData = map['data'];
    return LoginApiResponseModel(
      status: map['status'] != null ? map['status'] as String : null,
      message: map['message'] != null ? map['message'] as String : null,
      data: rawData is Map<String, dynamic>
          ? LoginApiResponseDataModel.fromMap(rawData)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginApiResponseModel.fromJson(String source) =>
      LoginApiResponseModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      'LoginApiResponseModel(status: $status, message: $message, data: $data)';
}

class LoginApiResponseDataModel {
  String? traceId;
  LoginApiResponseDataModel({this.traceId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'traceId': traceId};
  }

  factory LoginApiResponseDataModel.fromMap(Map<String, dynamic> map) {
    return LoginApiResponseDataModel(
      traceId: map['traceId'] != null ? map['traceId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginApiResponseDataModel.fromJson(String source) =>
      LoginApiResponseDataModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() => 'LoginApiResponseDataModel(traceId: $traceId)';
}
