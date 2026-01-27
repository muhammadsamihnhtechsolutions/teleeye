import 'dart:convert';

class MedicationTrackerApiResponse {
  MedicationTrackerApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  final String status;
  final String message;
  final MedicationTrackerApiResponseData? data;

  factory MedicationTrackerApiResponse.fromMap(Map<String, dynamic> map) {
    final List<dynamic> listOfMedications = (map['data'] as List?) ?? const [];

    // Group by title, merge day/time into a single Medication item
    final uniqueTitles = listOfMedications
        .map((e) => (e as Map<String, dynamic>)['title'])
        .whereType<String>()
        .toSet()
        .toList();

    final meds = <Medication>[];

    for (final t in uniqueTitles) {
      final List<Map<String, dynamic>> grouped = listOfMedications
          .where((e) => (e as Map<String, dynamic>)['title'] == t)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      if (grouped.isEmpty) continue;

      final dayList = grouped
          .map((e) => e['day']?.toString())
          .whereType<String>()
          .toSet()
          .toList();

      final timeList = grouped
          .map((e) => e['time']?.toString())
          .whereType<String>()
          .toSet()
          .toList();

      final first = grouped.first;
      meds.add(
        Medication(
          id: first['_id']?.toString(),
          originalTitle: first['title']?.toString(),
          patient: first['patient']?.toString(),
          title: first['title']?.toString(),
          description: first['description']?.toString(),
          sat: dayList.contains('sat'),
          sun: dayList.contains('sun'),
          mon: dayList.contains('mon'),
          tue: dayList.contains('tue'),
          wed: dayList.contains('wed'),
          thu: dayList.contains('thu'),
          fri: dayList.contains('fri'),
          status: first['status']?.toString(),
          createdAt: first['createdAt']?.toString(),
          updatedAt: first['updatedAt']?.toString(),
          time: timeList,
        ),
      );
    }

    return MedicationTrackerApiResponse(
      status: map['status']?.toString() ?? 'error',
      message: map['message']?.toString() ?? '',
      data: MedicationTrackerApiResponseData(docs: meds),
    );
  }

  factory MedicationTrackerApiResponse.fromJson(String source) =>
      MedicationTrackerApiResponse.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  Map<String, dynamic> toMap() => {
    'status': status,
    'message': message,
    'data': data?.toMap(),
  };

  String toJson() => json.encode(toMap());
}

class MedicationTrackerApiResponseData {
  MedicationTrackerApiResponseData({
    this.docs,
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

  final List<Medication>? docs;
  final int? totalDocs;
  final int? limit;
  final int? page;
  final int? totalPages;
  final int? pagingCounter;
  final bool? hasPrevPage;
  final bool? hasNextPage;
  final String? prevPage;
  final String? nextPage;

  Map<String, dynamic> toMap() => {
    'docs': docs?.map((e) => e.toMap()).toList(),
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

class Medication {
  Medication({
    this.id,
    this.originalTitle,
    this.patient,
    this.title,
    this.description,
    required this.time,
    this.sat,
    this.sun,
    this.mon,
    this.tue,
    this.wed,
    this.thu,
    this.fri,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  String? id;
  String? originalTitle;
  String? patient;
  String? title;
  String? description;
  List<String> time;
  bool? sat;
  bool? sun;
  bool? mon;
  bool? tue;
  bool? wed;
  bool? thu;
  bool? fri;
  String? status;
  String? createdAt;
  String? updatedAt;

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['_id']?.toString(),
      originalTitle:
          map['originalTitle']?.toString() ?? map['title']?.toString(),
      patient: map['patient']?.toString(),
      title: map['title']?.toString(),
      description: map['description']?.toString(),
      sat: map['sat'] as bool?,
      sun: map['sun'] as bool?,
      mon: map['mon'] as bool?,
      tue: map['tue'] as bool?,
      wed: map['wed'] as bool?,
      thu: map['thu'] as bool?,
      fri: map['fri'] as bool?,
      status: map['status']?.toString(),
      createdAt: map['createdAt']?.toString(),
      updatedAt: map['updatedAt']?.toString(),
      time: List<String>.from(
        (map['time'] as List? ?? const []).map((e) => e.toString()),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'originalTitle': originalTitle,
    'patient': patient,
    'title': title,
    'description': description,
    'time': time,
    'sat': sat ?? false,
    'sun': sun ?? false,
    'mon': mon ?? false,
    'tue': tue ?? false,
    'wed': wed ?? false,
    'thu': thu ?? false,
    'fri': fri ?? false,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class UpdateMedicationApiResponse {
  UpdateMedicationApiResponse({required this.status, required this.message});

  final String status;
  final String message;

  factory UpdateMedicationApiResponse.fromMap(Map<String, dynamic> map) {
    return UpdateMedicationApiResponse(
      status: map['status']?.toString() ?? 'error',
      message: map['message']?.toString() ?? 'An error occurred',
    );
  }
}
