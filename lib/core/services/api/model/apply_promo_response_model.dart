import 'dart:convert';

ApplyPromo applyPromoFromJson(String str) =>
    ApplyPromo.fromJson(json.decode(str));

String applyPromoToJson(ApplyPromo data) => json.encode(data.toJson());

class ApplyPromo {
  String? status;
  String? message;
  ApplyPromoData? data;

  ApplyPromo({this.status, this.message, this.data});

  factory ApplyPromo.fromJson(Map<String, dynamic> json) => ApplyPromo(
    status: json['status'],
    message: json['message'],
    data: json['data'] == null ? null : ApplyPromoData.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class ApplyPromoData {
  String? id;
  String? appointmentType;
  String? patient;
  String? doctor;
  int? weight;
  int? age;
  String? reason;
  String? description;
  bool? isPaid;
  dynamic paymentId;
  dynamic paymentMethod;
  bool? notifiedForFollowUp;
  DateTime? date;
  List<String>? eyePhotos;
  List<dynamic>? additionalFiles;
  String? promoCode;
  int? callDurationInSec;
  int? totalAmount;
  int? usdTotalAmount;
  int? fee;
  int? usdFee;
  double? vat;
  int? discount;
  double? usdVat;
  int? usdDiscount;
  double? grandTotal;
  double? usdGrandTotal;
  bool? isPrescribed;
  bool? notifiedForRating;
  bool? hasRating;
  dynamic doctorAgoraToken;
  dynamic patientAgoraToken;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ApplyPromoData({
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
    this.callDurationInSec,
    this.totalAmount,
    this.usdTotalAmount,
    this.fee,
    this.usdFee,
    this.vat,
    this.discount,
    this.usdVat,
    this.usdDiscount,
    this.grandTotal,
    this.usdGrandTotal,
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

  factory ApplyPromoData.fromJson(Map<String, dynamic> json) => ApplyPromoData(
    id: json['_id'],
    appointmentType: json['appointmentType'],
    patient: json['patient'],
    doctor: json['doctor'],
    weight: json['weight'],
    age: json['age'],
    reason: json['reason'],
    description: json['description'],
    isPaid: json['isPaid'],
    paymentId: json['paymentId'],
    paymentMethod: json['paymentMethod'],
    notifiedForFollowUp: json['notifiedForFollowUp'],
    date: json['date'] == null ? null : DateTime.parse('${json['date']}'),
    eyePhotos: json['eyePhotos'] == null
        ? <String>[]
        : List<String>.from((json['eyePhotos'] as List).map((x) => '$x')),
    additionalFiles: json['additionalFiles'] == null
        ? <dynamic>[]
        : List<dynamic>.from((json['additionalFiles'] as List).map((x) => x)),
    promoCode: json['promoCode'],
    callDurationInSec: json['callDurationInSec'],
    totalAmount: json['totalAmount'],
    usdTotalAmount: json['usdTotalAmount'],
    fee: json['fee'],
    usdFee: json['usdFee'],
    vat: (json['vat'] is num) ? (json['vat'] as num).toDouble() : null,
    discount: json['discount'],
    usdVat: (json['usdVat'] is num) ? (json['usdVat'] as num).toDouble() : null,
    usdDiscount: json['usdDiscount'],
    grandTotal: (json['grandTotal'] is num)
        ? (json['grandTotal'] as num).toDouble()
        : null,
    usdGrandTotal: (json['usdGrandTotal'] is num)
        ? (json['usdGrandTotal'] as num).toDouble()
        : null,
    isPrescribed: json['isPrescribed'],
    notifiedForRating: json['notifiedForRating'],
    hasRating: json['hasRating'],
    doctorAgoraToken: json['doctorAgoraToken'],
    patientAgoraToken: json['patientAgoraToken'],
    status: json['status'],
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse('${json['createdAt']}'),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse('${json['updatedAt']}'),
    v: json['__v'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'appointmentType': appointmentType,
    'patient': patient,
    'doctor': doctor,
    'weight': weight,
    'age': age,
    'reason': reason,
    'description': description,
    'isPaid': isPaid,
    'paymentId': paymentId,
    'paymentMethod': paymentMethod,
    'notifiedForFollowUp': notifiedForFollowUp,
    'date': date?.toIso8601String(),
    'eyePhotos': eyePhotos == null
        ? []
        : List<dynamic>.from(eyePhotos!.map((x) => x)),
    'additionalFiles': additionalFiles == null
        ? []
        : List<dynamic>.from(additionalFiles!.map((x) => x)),
    'promoCode': promoCode,
    'callDurationInSec': callDurationInSec,
    'totalAmount': totalAmount,
    'usdTotalAmount': usdTotalAmount,
    'fee': fee,
    'usdFee': usdFee,
    'vat': vat,
    'discount': discount,
    'usdVat': usdVat,
    'usdDiscount': usdDiscount,
    'grandTotal': grandTotal,
    'usdGrandTotal': usdGrandTotal,
    'isPrescribed': isPrescribed,
    'notifiedForRating': notifiedForRating,
    'hasRating': hasRating,
    'doctorAgoraToken': doctorAgoraToken,
    'patientAgoraToken': patientAgoraToken,
    'status': status,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    '__v': v,
  };
}
