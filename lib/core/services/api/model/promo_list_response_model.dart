import 'dart:convert';

PromoResponseModel promoResponseModelFromJson(String str) =>
    PromoResponseModel.fromJson(json.decode(str));

String promoResponseModelToJson(PromoResponseModel data) =>
    json.encode(data.toJson());

class PromoResponseModel {
  String? status;
  String? message;
  PromoResponseData? promoResponseData;

  PromoResponseModel({this.status, this.message, this.promoResponseData});

  factory PromoResponseModel.fromJson(Map<String, dynamic> json) =>
      PromoResponseModel(
        status: json['status'],
        message: json['message'],
        promoResponseData: json['data'] == null
            ? null
            : PromoResponseData.fromJson(json['data']),
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': promoResponseData?.toJson(),
  };
}

class PromoResponseData {
  List<Promo>? promoList;
  int? totalDocs;
  int? limit;
  int? page;
  int? totalPages;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  PromoResponseData({
    this.promoList,
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

  factory PromoResponseData.fromJson(Map<String, dynamic> json) =>
      PromoResponseData(
        promoList: json['docs'] == null
            ? <Promo>[]
            : List<Promo>.from(
                (json['docs'] as List).map((x) => Promo.fromJson(x)),
              ),
        totalDocs: json['totalDocs'],
        limit: json['limit'],
        page: json['page'],
        totalPages: json['totalPages'],
        pagingCounter: json['pagingCounter'],
        hasPrevPage: json['hasPrevPage'],
        hasNextPage: json['hasNextPage'],
        prevPage: json['prevPage'],
        nextPage: json['nextPage'],
      );

  Map<String, dynamic> toJson() => {
    'docs': promoList == null
        ? []
        : List<dynamic>.from(promoList!.map((x) => x.toJson())),
    'totalDocs': totalDocs,
    'limit': limit,
    'page': page,
    'totalPages': totalPages,
    'pagingCounter': pagingCounter,
    'hasPrevPage': hasPrevPage,
    'hasNextPage': hasNextPage,
    'prevPage': prevPage,
    'nextPage': nextPage,
  };
}

class Promo {
  String? id;
  String? code;
  int? discount;
  int? minimumPurchase;
  int? maximumDiscount;
  String? validFrom;
  String? validTill;
  String? discountFor;
  List<String>? selectedUsers;
  String? status;

  Promo({
    this.id,
    this.code,
    this.discount,
    this.minimumPurchase,
    this.maximumDiscount,
    this.validFrom,
    this.validTill,
    this.discountFor,
    this.selectedUsers,
    this.status,
  });

  factory Promo.fromJson(Map<String, dynamic> json) => Promo(
    id: json['_id'],
    code: json['code'],
    discount: json['discount'],
    minimumPurchase: json['minimumPurchase'],
    maximumDiscount: json['maximumDiscount'],
    validFrom: json['validFrom'],
    validTill: json['validTill'],
    discountFor: json['discountFor'],
    selectedUsers: json['selectedUsers'] == null
        ? <String>[]
        : List<String>.from((json['selectedUsers'] as List).map((x) => x)),
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'code': code,
    'discount': discount,
    'minimumPurchase': minimumPurchase,
    'maximumDiscount': maximumDiscount,
    'validFrom': validFrom,
    'validTill': validTill,
    'discountFor': discountFor,
    'selectedUsers': selectedUsers == null
        ? []
        : List<dynamic>.from(selectedUsers!.map((x) => x)),
    'status': status,
  };
}
