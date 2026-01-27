// To parse this JSON data, do
//
//     final doctorListResponseModel = doctorListResponseModelFromJson(jsonString);

import 'dart:convert';

DoctorListResponseModel doctorListResponseModelFromJson(String str) =>
    DoctorListResponseModel.fromJson(json.decode(str));

String doctorListResponseModelToJson(DoctorListResponseModel data) =>
    json.encode(data.toJson());

class DoctorListResponseModel {
  String? status;
  String? message;
  DoctorListResponseData? doctorListResponseData;

  DoctorListResponseModel({
    this.status,
    this.message,
    this.doctorListResponseData,
  });

  factory DoctorListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    return DoctorListResponseModel(
      status: json["status"],
      message: json["message"],
      doctorListResponseData: data is Map<String, dynamic>
          ? DoctorListResponseData.fromJson(data)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": doctorListResponseData?.toJson(),
  };
}

class DoctorListResponseData {
  List<Doctor>? doctorList;
  int? totalDocs;
  int? limit;
  int? page;
  int? totalPages;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  String? prevPage;
  String? nextPage;

  DoctorListResponseData({
    this.doctorList,
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

  factory DoctorListResponseData.fromJson(Map<String, dynamic> json) {
    final docs = json["docs"];
    return DoctorListResponseData(
      doctorList: docs is List
          ? List<Doctor>.from(
              docs.map((x) => Doctor.fromJson(x as Map<String, dynamic>)),
            )
          : <Doctor>[],
      totalDocs: json["totalDocs"],
      limit: json["limit"],
      page: json["page"],
      totalPages: json["totalPages"],
      pagingCounter: json["pagingCounter"],
      hasPrevPage: json["hasPrevPage"],
      hasNextPage: json["hasNextPage"],
      prevPage: json["prevPage"] != null ? "${json["prevPage"]}" : "",
      nextPage: json["nextPage"] != null ? "${json["nextPage"]}" : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "docs": doctorList == null
        ? []
        : List<dynamic>.from(doctorList!.map((x) => x.toJson())),
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
} // To parse this JSON data, do
//
//     final doctor = doctorFromJson(jsonString);

Doctor doctorFromJson(String str) => Doctor.fromJson(json.decode(str));

String doctorToJson(Doctor data) => json.encode(data.toJson());

class Doctor {
  String? id;
  String? phone;
  int? v;
  String? about;
  String? availabilityStatus;
  int? averageConsultancyTime;
  double? averageRating;
  int? averageResponseTime;
  String? bmdcCode;
  int? consultationFee;
  DateTime? createdAt;
  List<String>? deviceTokens;
  String? dialCode;
  double? experienceInYear;
  int? followupFee;
  String? gender;
  String? name;
  String? photo;
  int? ratingCount;
  String? signature;
  String? status;
  int? totalConsultationCount;
  DateTime? updatedAt;
  List<Hospital> hospital;
  List<Specialty> specialty;
  List<Experience>? experiences;
  bool? isFavorite;
  double? consultationFeeUsd;
  double? followUpFeeUsd;

  Doctor({
    this.id,
    this.phone,
    this.v,
    this.about,
    this.availabilityStatus,
    this.averageConsultancyTime,
    this.averageRating,
    this.averageResponseTime,
    this.bmdcCode,
    this.consultationFee,
    this.createdAt,
    this.deviceTokens,
    this.dialCode,
    this.experienceInYear,
    this.followupFee,
    this.gender,
    this.name,
    this.photo,
    this.ratingCount,
    this.signature,
    this.status,
    this.totalConsultationCount,
    this.updatedAt,
    this.hospital = const [],
    this.specialty = const [],
    this.experiences,
    this.isFavorite,
    this.consultationFeeUsd,
    this.followUpFeeUsd,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final hospitalJson = json["hospital"];
    final specialtyJson = json["specialty"];
    final experiencesJson = json["experiences"];

    final avgRatingRaw = json["averageRating"];
    final avgRatingParsed = avgRatingRaw == null
        ? null
        : double.tryParse(avgRatingRaw.toString());

    final feeUsdRaw = json["consultationFeeUsd"];
    final feeUsdParsed = feeUsdRaw == null
        ? null
        : double.tryParse(feeUsdRaw.toString());

    final followUpUsdRaw = json["followUpFeeUsd"];
    final followUpUsdParsed = followUpUsdRaw == null
        ? null
        : double.tryParse(followUpUsdRaw.toString());

    return Doctor(
      id: json["_id"],
      phone: json["phone"],
      v: json["__v"],
      about: json["about"],
      availabilityStatus: json["availabilityStatus"],
      averageConsultancyTime: json["averageConsultancyTime"],
      averageRating: avgRatingParsed == null
          ? 0.0
          : double.parse(avgRatingParsed.toStringAsFixed(2)),
      averageResponseTime: json["averageResponseTime"],
      bmdcCode: json["bmdcCode"] != null ? json["bmdcCode"] : "",
      consultationFee: json["consultationFee"],
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),
      // deviceTokens: json["deviceTokens"] == null ? [] : List<String>.from(json["deviceTokens"]!.map((x) => x)),
      dialCode: json["dialCode"],
      experienceInYear: json["experienceInYear"] != null
          ? double.tryParse(json["experienceInYear"].toString())
          : null,
      followupFee: json["followupFee"],
      gender: json["gender"],
      name: json["name"],
      photo: json["photo"],
      ratingCount: json["ratingCount"],
      signature: json["signature"],
      status: json["status"],
      totalConsultationCount: json["totalConsultationCount"],
      updatedAt: json["updatedAt"] == null
          ? null
          : DateTime.parse(json["updatedAt"]),
      hospital: hospitalJson is List
          ? List<Hospital>.from(
              hospitalJson.map(
                (e) => Hospital.fromJson(e as Map<String, dynamic>),
              ),
            )
          : <Hospital>[],
      specialty: specialtyJson is List
          ? List<Specialty>.from(
              specialtyJson.map(
                (e) => Specialty.fromJson(e as Map<String, dynamic>),
              ),
            )
          : <Specialty>[],
      experiences: experiencesJson is List
          ? List<Experience>.from(
              experiencesJson.map(
                (x) => Experience.fromJson(x as Map<String, dynamic>),
              ),
            )
          : <Experience>[],
      isFavorite: json["isFavorite"],
      consultationFeeUsd: feeUsdParsed == null
          ? 0.0
          : double.parse(feeUsdParsed.toStringAsFixed(2)),
      followUpFeeUsd: followUpUsdParsed == null
          ? 0.0
          : double.parse(followUpUsdParsed.toStringAsFixed(2)),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phone": phone,
    "__v": v,
    "about": about,
    "availabilityStatus": availabilityStatus,
    "averageConsultancyTime": averageConsultancyTime,
    "averageRating": averageRating,
    "averageResponseTime": averageResponseTime,
    "bmdcCode": bmdcCode,
    "consultationFee": consultationFee,
    "createdAt": createdAt?.toIso8601String(),
    "deviceTokens": deviceTokens == null
        ? []
        : List<dynamic>.from(deviceTokens!.map((x) => x)),
    "dialCode": dialCode,
    "experienceInYear": experienceInYear,
    "followupFee": followupFee,
    "gender": gender,
    "name": name,
    "photo": photo,
    "ratingCount": ratingCount,
    "signature": signature,
    "status": status,
    "totalConsultationCount": totalConsultationCount,
    "updatedAt": updatedAt?.toIso8601String(),
    "hospital": hospital.map((e) => e.toJson()).toList(),
    "specialty": specialty.map((e) => e.toJson()).toList(),
    "experiences": experiences == null
        ? []
        : List<dynamic>.from(experiences!.map((x) => x.toJson())),
    "isFavorite": isFavorite,
    "followUpFeeUsd": followUpFeeUsd,
    "consultationFeeUsd": consultationFeeUsd,
  };
}

class Experience {
  String? id;
  String? doctor;
  String? hospitalName;
  String? designation;
  String? department;
  DateTime? startDate;
  DateTime? endDate;
  bool? currentlyWorkingHere;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;

  Experience({
    this.id,
    this.doctor,
    this.hospitalName,
    this.designation,
    this.department,
    this.startDate,
    this.endDate,
    this.currentlyWorkingHere,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    id: json["_id"],
    doctor: json["doctor"],
    hospitalName: json["hospitalName"],
    designation: json["designation"],
    department: json["department"],
    startDate: json["startDate"] == null
        ? null
        : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    currentlyWorkingHere: json["currentlyWorkingHere"],
    v: json["__v"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "doctor": doctor,
    "hospitalName": hospitalName,
    "designation": designation,
    "department": department,
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "currentlyWorkingHere": currentlyWorkingHere,
    "__v": v,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Hospital {
  String? id;
  String? name;
  String? address;
  Location? location;
  String? description;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Hospital({
    this.id,
    this.name,
    this.address,
    this.location,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
    id: json["_id"],
    name: json["name"],
    address: json["address"],
    location: json["location"] == null
        ? null
        : Location.fromJson(json["location"]),
    description: json["description"],
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
    "name": name,
    "address": address,
    "location": location?.toJson(),
    "description": description,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"],
    coordinates: json["coordinates"] is List
        ? (json["coordinates"] as List)
              .map((x) => x == null ? null : double.tryParse(x.toString()))
              .whereType<double>()
              .toList()
        : <double>[],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null
        ? []
        : List<dynamic>.from(coordinates!.map((x) => x)),
  };
}

class Specialty {
  String? id;
  String? title;
  String? symptoms;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Specialty({
    this.id,
    this.title,
    this.symptoms,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) => Specialty(
    id: json["_id"],
    title: json["title"],
    symptoms: json["symptoms"],
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
    "title": title,
    "symptoms": symptoms,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
