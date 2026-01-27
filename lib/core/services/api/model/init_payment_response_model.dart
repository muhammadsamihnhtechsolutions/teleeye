// To parse this JSON data, do
//
//     final initPaymentApiResponseModel = initPaymentApiResponseModelFromJson(jsonString);

import 'dart:convert';

InitPaymentApiResponseModel initPaymentApiResponseModelFromJson(String str) =>
    InitPaymentApiResponseModel.fromJson(json.decode(str));

String initPaymentApiResponseModelToJson(InitPaymentApiResponseModel data) =>
    json.encode(data.toJson());

class InitPaymentApiResponseModel {
  String? status;
  String? message;
  String? url;

  InitPaymentApiResponseModel({this.status, this.message, this.url});

  InitPaymentApiResponseModel copyWith({
    String? status,
    String? message,
    String? url,
  }) => InitPaymentApiResponseModel(
    status: status ?? this.status,
    message: message ?? this.message,
    url: url ?? this.url,
  );

  factory InitPaymentApiResponseModel.fromJson(Map<String, dynamic> json) =>
      InitPaymentApiResponseModel(
        status: json["status"],
        message: json["message"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "url": url,
  };
}
