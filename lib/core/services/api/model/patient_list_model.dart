// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class GetPatientListApiResponse {
  String status;
  String message;
  List<MyPatient>? data;
  GetPatientListApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  GetPatientListApiResponse copyWith({
    String? status,
    String? message,
    List<MyPatient>? data,
  }) {
    return GetPatientListApiResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'message': message,
      'data': data?.map((x) => x.toMap()).toList(),
    };
  }

  factory GetPatientListApiResponse.fromMap(Map<String, dynamic> map) {
    return GetPatientListApiResponse(
      status: map['status'] as String,
      message: map['message'] as String,
      data: map['data'] != null
          ? List<MyPatient>.from(
              (map['data'] as List).map<MyPatient?>(
                (x) => MyPatient.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GetPatientListApiResponse.fromJson(String source) =>
      GetPatientListApiResponse.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      'GetPatientListApiResponse(status: $status, message: $message, data: $data)';

  @override
  bool operator ==(covariant GetPatientListApiResponse other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.message == message &&
        listEquals(other.data, data);
  }

  @override
  int get hashCode => status.hashCode ^ message.hashCode ^ data.hashCode;
}

class MyPatient {
  String? id;
  String? name;
  String? gender;
  String? weight;
  String? relation;
  String? dateOfBirth;
  String? photo;
  MyPatient({
    this.id,
    this.name,
    this.gender,
    this.weight,
    this.relation,
    this.dateOfBirth,
    this.photo,
  });

  MyPatient copyWith({
    String? id,
    String? name,
    String? gender,
    String? weight,
    String? relation,
    String? dateOfBirth,
    String? photo,
  }) {
    return MyPatient(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      relation: relation ?? this.relation,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'gender': gender,
      'weight': weight,
      'relation': relation,
      'dateOfBirth': dateOfBirth,
      'photo': photo,
    };
  }

  factory MyPatient.fromMap(Map<String, dynamic> map) {
    return MyPatient(
      id: (map['_id'] ?? map['id']) != null
          ? (map['_id'] ?? map['id']) as String
          : null,
      name: map['name'] != null ? map['name'] as String : null,
      gender: map['gender'] != null ? map['gender'] as String : null,
      weight: map['weight'] != null ? map['weight'] as String : null,
      relation: map['relation'] != null ? map['relation'] as String : "",
      dateOfBirth: map['dateOfBirth'] != null
          ? map['dateOfBirth'] as String
          : null,
      photo: map['photo'] != null ? map['photo'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MyPatient.fromJson(String source) =>
      MyPatient.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MyPatient(id: $id, name: $name, gender: $gender, weight: $weight, relation: $relation, dateOfBirth: $dateOfBirth, photo: $photo)';
  }

  @override
  bool operator ==(covariant MyPatient other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.gender == gender &&
        other.weight == weight &&
        other.relation == relation &&
        other.dateOfBirth == dateOfBirth &&
        other.photo == photo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        gender.hashCode ^
        weight.hashCode ^
        relation.hashCode ^
        dateOfBirth.hashCode ^
        photo.hashCode;
  }
}
