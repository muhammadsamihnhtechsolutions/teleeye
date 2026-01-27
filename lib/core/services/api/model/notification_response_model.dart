// To parse this JSON data, do
//
//     final notificationResponseModel = notificationResponseModelFromJson(jsonString);

import 'dart:convert';

NotificationResponseModel notificationResponseModelFromJson(String str) =>
    NotificationResponseModel.fromJson(json.decode(str));

String notificationResponseModelToJson(NotificationResponseModel data) =>
    json.encode(data.toJson());

class NotificationResponseModel {
  String? status;
  String? message;
  NotificationData? notificationData;

  NotificationResponseModel({this.status, this.message, this.notificationData});

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) =>
      NotificationResponseModel(
        status: json["status"],
        message: json["message"],
        notificationData: json["data"] == null
            ? null
            : NotificationData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": notificationData?.toJson(),
  };
}

class NotificationData {
  List<NotificationModel>? notificationList;
  int? totalDocs;
  int? limit;
  int? page;
  int? totalPages;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  int? nextPage;

  NotificationData({
    this.notificationList,
    this.totalDocs,
    this.limit,
    this.page,
    this.totalPages,
    this.pagingCounter,
    this.hasPrevPage,
    this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        notificationList: json["docs"] == null
            ? []
            : List<NotificationModel>.from(
                json["docs"]!.map((x) => NotificationModel.fromJson(x)),
              ),
        totalDocs: json["totalDocs"],
        limit: json["limit"],
        page: json["page"],
        totalPages: json["totalPages"],
        pagingCounter: json["pagingCounter"],
        hasPrevPage: json["hasPrevPage"],
        hasNextPage: json["hasNextPage"],
        prevPage: json["prevPage"],
        nextPage: json["nextPage"],
      );

  Map<String, dynamic> toJson() => {
    "docs": notificationList == null
        ? []
        : List<dynamic>.from(notificationList!.map((x) => x.toJson())),
    "totalDocs": totalDocs,
    "limit": limit,
    "page": page,
    "totalPages": totalPages,
    "pagingCounter": pagingCounter,
    "hasPrevPage": hasPrevPage,
    "hasNextPage": hasNextPage,
    "prevPage": prevPage,
    "nextPage": nextPage,
  };
}

class NotificationModel {
  String? id;
  String? title;
  String? body;
  String? criteria;
  String? type;
  NotificationMetaData? metaData;
  String? createdAt;

  NotificationModel({
    this.id,
    this.title,
    this.body,
    this.criteria,
    this.type,
    this.metaData,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["_id"],
        title: json["title"],
        body: json["body"],
        criteria: json["criteria"],
        type: json["type"],
        metaData: json["metaData"] == null
            ? null
            : NotificationMetaData.fromJson(json["metaData"]),
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "body": body,
    "criteria": criteria,
    "type": type,
    "metaData": metaData?.toJson(),
    "createdAt": createdAt,
  };
}

class NotificationMetaData {
  String? id;
  String? appointmentType;
  String? patient;
  String? doctor;
  double? weight;
  int? age;
  String? reason;
  String? description;
  bool? isPaid;
  String? paymentId;
  String? paymentMethod;
  bool? notifiedForFollowUp;
  String? date;
  List<String>? eyePhotos;
  List<dynamic>? additionalFiles;
  String? promoCode;
  double? totalAmount;
  double? fee;
  double? vat;
  double? discount;
  double? grandTotal;
  bool? isPrescribed;
  bool? notifiedForRating;
  bool? hasRating;
  String? doctorAgoraToken;
  String? patientAgoraToken;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? v;

  NotificationMetaData({
    this.id,
    this.appointmentType,
    this.patient,
    this.doctor,
    this.weight,
    this.age,
    this.reason,
    this.description,
    this.isPaid,
    this.paymentId,
    this.paymentMethod,
    this.notifiedForFollowUp,
    this.date,
    this.eyePhotos,
    this.additionalFiles,
    this.promoCode,
    this.totalAmount,
    this.fee,
    this.vat,
    this.discount,
    this.grandTotal,
    this.isPrescribed,
    this.notifiedForRating,
    this.hasRating,
    this.doctorAgoraToken,
    this.patientAgoraToken,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory NotificationMetaData.fromJson(Map<String, dynamic> json) =>
      NotificationMetaData(
        id: json["_id"],
        appointmentType: json["appointmentType"],
        patient: json["patient"],
        doctor: json["doctor"],
        weight: json["weight"] != null
            ? double.parse("${json["weight"]}")
            : 0.0,
        age: json["age"],
        reason: json["reason"],
        description: json["description"],
        isPaid: json["isPaid"],
        paymentId: json["paymentId"],
        paymentMethod: json["paymentMethod"],
        notifiedForFollowUp: json["notifiedForFollowUp"],
        date: json["date"] == null ? "" : "${json["date"]}",
        eyePhotos: json["eyePhotos"] == null
            ? []
            : List<String>.from(json["eyePhotos"]!.map((x) => x)),
        additionalFiles: json["additionalFiles"] == null
            ? []
            : List<dynamic>.from(json["additionalFiles"]!.map((x) => x)),
        promoCode: json["promoCode"] != null ? "${json["promoCode"]}" : "",
        totalAmount: json["totalAmount"] != null
            ? double.parse("${json["totalAmount"]}")
            : 0.0,
        fee: json["fee"] != null ? double.parse("${json["fee"]}") : 0.0,
        vat: json["vat"] != null ? double.parse("${json["vat"]}") : 0.0,
        discount: json["discount"] != null
            ? double.parse("${json["discount"]}")
            : 0.0,
        grandTotal: json["grandTotal"] != null
            ? double.parse("${json["grandTotal"]}")
            : 0.0,
        isPrescribed: json["isPrescribed"],
        notifiedForRating: json["notifiedForRating"],
        hasRating: json["hasRating"],
        doctorAgoraToken: json["doctorAgoraToken"],
        patientAgoraToken: json["patientAgoraToken"],
        status: json["status"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "appointmentType": appointmentType,
    "patient": patient,
    "doctor": doctor,
    "weight": weight,
    "age": age,
    "reason": reason,
    "description": description,
    "isPaid": isPaid,
    "paymentId": paymentId,
    "paymentMethod": paymentMethod,
    "notifiedForFollowUp": notifiedForFollowUp,
    "date": date,
    "eyePhotos": eyePhotos == null
        ? []
        : List<dynamic>.from(eyePhotos!.map((x) => x)),
    "additionalFiles": additionalFiles == null
        ? []
        : List<dynamic>.from(additionalFiles!.map((x) => x)),
    "promoCode": promoCode,
    "totalAmount": totalAmount,
    "fee": fee,
    "vat": vat,
    "discount": discount,
    "grandTotal": grandTotal,
    "isPrescribed": isPrescribed,
    "notifiedForRating": notifiedForRating,
    "hasRating": hasRating,
    "doctorAgoraToken": doctorAgoraToken,
    "patientAgoraToken": patientAgoraToken,
    "status": status,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}
