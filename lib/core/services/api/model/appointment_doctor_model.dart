// To parse this JSON data, do
//
//     final getAppointmentApiResponse = getAppointmentApiResponseFromJson(jsonString);

import 'dart:convert';

GetAppointmentApiResponse getAppointmentApiResponseFromJson(String str) =>
    GetAppointmentApiResponse.fromJson(json.decode(str));

String getAppointmentApiResponseToJson(GetAppointmentApiResponse data) =>
    json.encode(data.toJson());

class GetAppointmentApiResponse {
  String? status;
  String? message;
  AppointmentList? appointmentList;

  GetAppointmentApiResponse({this.status, this.message, this.appointmentList});

  factory GetAppointmentApiResponse.fromJson(Map<String, dynamic> json) =>
      GetAppointmentApiResponse(
        status: json["status"],
        message: json["message"],
        appointmentList: json["data"] == null
            ? null
            : AppointmentList.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": appointmentList?.toJson(),
  };
}

class AppointmentList {
  List<AppointmentData>? appointmentData;
  int? totalDocs;
  int? limit;
  int? page;
  int? totalPages;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  int? prevPage;
  int? nextPage;

  AppointmentList({
    this.appointmentData,
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

  factory AppointmentList.fromJson(Map<String, dynamic> json) =>
      AppointmentList(
        appointmentData: json["docs"] == null
            ? []
            : List<AppointmentData>.from(
                json["docs"]!.map((x) => AppointmentData.fromJson(x)),
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
    "docs": appointmentData == null
        ? []
        : List<dynamic>.from(appointmentData!.map((x) => x.toJson())),
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

// To parse this JSON data, do
//
//     final appointmentData = appointmentDataFromJson(jsonString);

AppointmentData appointmentDataFromJson(String str) =>
    AppointmentData.fromJson(json.decode(str));

String appointmentDataToJson(AppointmentData data) =>
    json.encode(data.toJson());

// To parse this JSON data, do
//
//     final rating = ratingFromJson(jsonString);

Rating ratingFromJson(String str) => Rating.fromJson(json.decode(str));

String ratingToJson(Rating data) => json.encode(data.toJson());

class Rating {
  String? id;
  String? appointment;
  String? patient;
  String? doctor;
  double? rating;
  String? review;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Rating({
    this.id,
    this.appointment,
    this.patient,
    this.doctor,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json["_id"],
    appointment: json["appointment"],
    patient: json["patient"],
    doctor: json["doctor"],
    rating: json["rating"]?.toDouble(),
    review: json["review"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "appointment": appointment,
    "patient": patient,
    "doctor": doctor,
    "rating": rating,
    "review": review,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class AppointmentData {
  String? id;
  String? appointmentType;
  AppointmentDoctor? doctor;
  double? weight;
  int? age;
  String? reason;
  String? description;
  String? paymentId;
  String? paymentMethod;
  String? date;
  List<String>? eyePhotos;
  List<String>? additionalFiles;
  dynamic promoCode;
  double? totalAmount;
  double? fee;
  double? vat;
  double? discount;
  double? grandTotal;
  bool? isPrescribed;
  int? callDurationInSec;
  bool? hasRating;
  String? doctorAgoraToken;
  String? patientAgoraToken;
  String? channelId;
  String? status;
  DateTime? createdAt;
  QueueStatus? queueStatus;
  Rating? rating;

  AppointmentData({
    this.id,
    this.appointmentType,
    this.doctor,
    this.weight,
    this.age,
    this.reason,
    this.description,
    this.paymentId,
    this.paymentMethod,
    this.date,
    this.eyePhotos,
    this.additionalFiles,
    this.promoCode,
    this.totalAmount,
    this.callDurationInSec,
    this.fee,
    this.vat,
    this.discount,
    this.grandTotal,
    this.isPrescribed,
    this.hasRating,
    this.doctorAgoraToken,
    this.patientAgoraToken,
    this.channelId,
    this.status,
    this.createdAt,
    this.queueStatus,
    this.rating,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) =>
      AppointmentData(
        id: json["_id"],
        appointmentType: json["appointmentType"],
        doctor: json["doctor"] == null
            ? null
            : AppointmentDoctor.fromJson(json["doctor"]),
        weight: json["weight"]?.toDouble(),
        age: json["age"],
        reason: json["reason"],
        description: json["description"],
        callDurationInSec: json["callDurationInSec"],
        paymentId: json["paymentId"],
        paymentMethod: json["paymentMethod"],
        date: json["date"] == null ? null : json["date"],
        eyePhotos: json["eyePhotos"] == null
            ? []
            : List<String>.from(json["eyePhotos"]!.map((x) => x)),
        additionalFiles: json["additionalFiles"] == null
            ? []
            : List<String>.from(json["additionalFiles"]!.map((x) => x)),
        promoCode: json["promoCode"],
        totalAmount: double.tryParse((json["totalAmount"] ?? "0.0").toString()),
        fee: double.tryParse((json["fee"] ?? "0.0").toString()),
        vat: double.tryParse((json["vat"] ?? "0.0").toString()),
        discount: double.tryParse((json["discount"] ?? "0.0").toString()),
        grandTotal: double.tryParse((json["grandTotal"] ?? "0.0").toString()),
        isPrescribed: json["isPrescribed"],
        hasRating: json["hasRating"],
        doctorAgoraToken: json["doctorAgoraToken"],
        patientAgoraToken: json["patientAgoraToken"],
        channelId: json["channelId"],
        status: json["status"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        queueStatus: json["queueStatus"] == null
            ? null
            : QueueStatus.fromJson(json["queueStatus"]),
        rating: json["rating"] == null ? null : Rating.fromJson(json["rating"]),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "appointmentType": appointmentType,
    "doctor": doctor?.toJson(),
    "weight": weight,
    "age": age,
    "reason": reason,
    "description": description,
    "paymentId": paymentId,
    "paymentMethod": paymentMethod,
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
    "callDurationInSec": callDurationInSec,
    "discount": discount,
    "grandTotal": grandTotal,
    "isPrescribed": isPrescribed,
    "hasRating": hasRating,
    "doctorAgoraToken": doctorAgoraToken,
    "patientAgoraToken": patientAgoraToken,
    "channelId": channelId,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "queueStatus": queueStatus?.toJson(),
  };
}

class QueueStatus {
  int? totalQueueCount;
  int? waitingTimeInMin;

  QueueStatus({this.totalQueueCount, this.waitingTimeInMin});

  factory QueueStatus.fromJson(Map<String, dynamic> json) => QueueStatus(
    totalQueueCount: json["totalQueueCount"],
    waitingTimeInMin: json["waitingTimeInMin"],
  );

  Map<String, dynamic> toJson() => {
    "totalQueueCount": totalQueueCount,
    "waitingTimeInMin": waitingTimeInMin,
  };
}

class AppointmentDoctor {
  String? id;
  String? phone;
  String? about;
  String? bmdcCode;
  String? dialCode;
  String? name;
  String? photo;

  AppointmentDoctor({
    this.id,
    this.phone,
    this.about,
    this.bmdcCode,
    this.dialCode,
    this.name,
    this.photo,
  });

  factory AppointmentDoctor.fromJson(Map<String, dynamic> json) =>
      AppointmentDoctor(
        id: json["_id"],
        phone: json["phone"],
        about: json["about"],
        bmdcCode: json["bmdcCode"],
        dialCode: json["dialCode"],
        name: json["name"],
        photo: json["photo"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phone": phone,
    "about": about,
    "bmdcCode": bmdcCode,
    "dialCode": dialCode,
    "name": name,
    "photo": photo,
  };
}

// To parse this JSON data, do
//
//     final appointmentMarkAsPaidApiResponseModel = appointmentMarkAsPaidApiResponseModelFromJson(jsonString);

AppointmentMarkAsPaidApiResponseModel
appointmentMarkAsPaidApiResponseModelFromJson(String str) =>
    AppointmentMarkAsPaidApiResponseModel.fromJson(json.decode(str));

String appointmentMarkAsPaidApiResponseModelToJson(
  AppointmentMarkAsPaidApiResponseModel data,
) => json.encode(data.toJson());

class AppointmentMarkAsPaidApiResponseModel {
  String? status;
  String? message;
  QueueStatus? queueStatus;
  Appointment? appointment;

  AppointmentMarkAsPaidApiResponseModel({
    this.status,
    this.message,
    this.queueStatus,
    this.appointment,
  });

  factory AppointmentMarkAsPaidApiResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => AppointmentMarkAsPaidApiResponseModel(
    status: json["status"],
    message: json["message"],
    queueStatus: json["queueStatus"] == null
        ? null
        : QueueStatus.fromJson(json["queueStatus"]),
    appointment: json["appointment"] == null
        ? null
        : Appointment.fromJson(json["appointment"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "queueStatus": queueStatus?.toJson(),
    "appointment": appointment?.toJson(),
  };
}

class Appointment {
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
  DateTime? date;
  List<String>? eyePhotos;
  List<String>? additionalFiles;
  dynamic promoCode;
  double? totalAmount;
  int? fee;
  double? vat;
  int? discount;
  double? grandTotal;
  bool? isPrescribed;
  bool? notifiedForRating;
  bool? hasRating;
  dynamic doctorAgoraToken;
  dynamic patientAgoraToken;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Appointment({
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

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json["_id"],
    appointmentType: json["appointmentType"],
    patient: json["patient"],
    doctor: json["doctor"],
    weight: json["weight"]?.toDouble(),
    age: json["age"],
    reason: json["reason"],
    description: json["description"],
    isPaid: json["isPaid"],
    paymentId: json["paymentId"],
    paymentMethod: json["paymentMethod"],
    notifiedForFollowUp: json["notifiedForFollowUp"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    eyePhotos: json["eyePhotos"] == null
        ? []
        : List<String>.from(json["eyePhotos"]!.map((x) => x)),
    additionalFiles: json["additionalFiles"] == null
        ? []
        : List<String>.from(json["additionalFiles"]!.map((x) => x)),
    promoCode: json["promoCode"],
    totalAmount: double.parse(json["totalAmount"].toString()),
    fee: json["fee"],
    vat: double.parse((json["vat"] ?? 0.0).toString()),
    discount: json["discount"],
    grandTotal: double.parse((json["grandTotal"] ?? 0.0).toString()),
    isPrescribed: json["isPrescribed"],
    notifiedForRating: json["notifiedForRating"],
    hasRating: json["hasRating"],
    doctorAgoraToken: json["doctorAgoraToken"],
    patientAgoraToken: json["patientAgoraToken"],
    status: json["status"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
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
    "date": date?.toIso8601String(),
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
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class SaveAppointmentApiResponse {
  String status;
  String message;
  Appointment? appointment;
  SaveAppointmentApiResponse({
    required this.status,
    required this.message,
    this.appointment,
  });

  SaveAppointmentApiResponse copyWith({
    String? status,
    String? message,
    Appointment? appointment,
  }) {
    return SaveAppointmentApiResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      appointment: appointment ?? this.appointment,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'message': message,
      'appointment': appointment?.toJson(),
    };
  }

  factory SaveAppointmentApiResponse.fromMap(Map<String, dynamic> map) {
    return SaveAppointmentApiResponse(
      status: map['status'].toString(),
      message: map['message'].toString(),
      appointment: map['appointment'] != null
          ? Appointment.fromJson(map['appointment'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SaveAppointmentApiResponse.fromJson(String source) =>
      SaveAppointmentApiResponse.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      'SaveAppointmentApiResponse(status: $status, message: $message, appointment: $appointment)';

  @override
  bool operator ==(covariant SaveAppointmentApiResponse other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.message == message &&
        other.appointment == appointment;
  }

  @override
  int get hashCode => status.hashCode ^ message.hashCode ^ appointment.hashCode;
}
