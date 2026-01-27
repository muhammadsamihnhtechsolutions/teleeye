import 'dart:convert';

GetDoctorRatingModel getDoctorRatingModelFromJson(String str) =>
    GetDoctorRatingModel.fromJson(json.decode(str) as Map<String, dynamic>);

String getDoctorRatingModelToJson(GetDoctorRatingModel data) =>
    json.encode(data.toJson());

class GetDoctorRatingModel {
  final String? status;
  final String? message;
  final GetDoctorRatingData? data;
  final List<GetDoctorRatingStatistic> statistics;

  const GetDoctorRatingModel({
    this.status,
    this.message,
    this.data,
    this.statistics = const [],
  });

  factory GetDoctorRatingModel.fromJson(Map<String, dynamic> json) {
    return GetDoctorRatingModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : GetDoctorRatingData.fromJson(json['data'] as Map<String, dynamic>),
      statistics: json['statistics'] == null
          ? const []
          : List<GetDoctorRatingStatistic>.from(
              (json['statistics'] as List).map(
                (e) => GetDoctorRatingStatistic.fromJson(
                  e as Map<String, dynamic>,
                ),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
    'statistics': List<dynamic>.from(statistics.map((e) => e.toJson())),
  };

  double get averageRating {
    if (statistics.isEmpty) return 0.0;
    double sum = 0.0;
    int count = 0;
    for (final s in statistics) {
      sum += (s.average ?? 0.0) * (s.count ?? 0);
      count += s.count ?? 0;
    }
    if (count == 0) return 0.0;
    return sum / count;
  }

  int get totalRatings {
    int count = 0;
    for (final s in statistics) {
      count += s.count ?? 0;
    }
    return count;
  }
}

class GetDoctorRatingData {
  final List<GetDoctorRatingDoc> docs;

  const GetDoctorRatingData({this.docs = const []});

  factory GetDoctorRatingData.fromJson(Map<String, dynamic> json) {
    return GetDoctorRatingData(
      docs: json['docs'] == null
          ? const []
          : List<GetDoctorRatingDoc>.from(
              (json['docs'] as List).map(
                (e) => GetDoctorRatingDoc.fromJson(e as Map<String, dynamic>),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'docs': List<dynamic>.from(docs.map((e) => e.toJson())),
  };
}

class GetDoctorRatingDoc {
  final String? id;
  final GetDoctorRatingPatient? patient;
  final String? doctor;
  final double? rating;
  final String? review;
  final DateTime? createdAt;

  const GetDoctorRatingDoc({
    this.id,
    this.patient,
    this.doctor,
    this.rating,
    this.review,
    this.createdAt,
  });

  factory GetDoctorRatingDoc.fromJson(Map<String, dynamic> json) {
    return GetDoctorRatingDoc(
      id: json['_id'] as String?,
      patient: json['patient'] == null
          ? null
          : GetDoctorRatingPatient.fromJson(
              json['patient'] as Map<String, dynamic>,
            ),
      doctor: json['doctor'] as String?,
      rating: json['rating'] == null
          ? null
          : double.tryParse(json['rating'].toString()),
      review: json['review'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'patient': patient?.toJson(),
    'doctor': doctor,
    'rating': rating,
    'review': review,
    'createdAt': createdAt?.toIso8601String(),
  };
}

class GetDoctorRatingPatient {
  final String? id;
  final String? name;
  final String? photo;

  const GetDoctorRatingPatient({this.id, this.name, this.photo});

  factory GetDoctorRatingPatient.fromJson(Map<String, dynamic> json) {
    return GetDoctorRatingPatient(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'photo': photo};
}

class GetDoctorRatingStatistic {
  final int? id;
  final int? count;
  final double? average;

  const GetDoctorRatingStatistic({this.id, this.count, this.average});

  factory GetDoctorRatingStatistic.fromJson(Map<String, dynamic> json) {
    return GetDoctorRatingStatistic(
      id: json['_id'] == null ? null : int.tryParse(json['_id'].toString()),
      count: json['count'] == null
          ? null
          : int.tryParse(json['count'].toString()),
      average: json['average'] == null
          ? null
          : double.tryParse(json['average'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'count': count,
    'average': average,
  };
}
