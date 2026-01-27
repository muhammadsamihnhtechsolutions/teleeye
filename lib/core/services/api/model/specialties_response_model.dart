import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';

class SpecialtiesResponseModel {
  String? status;
  String? message;
  List<Specialty>? specialtyList;

  SpecialtiesResponseModel({this.status, this.message, this.specialtyList});

  factory SpecialtiesResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SpecialtiesResponseModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      specialtyList: data is List
          ? List<Specialty>.from(
              data.map((e) => Specialty.fromJson(e as Map<String, dynamic>)),
            )
          : <Specialty>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': specialtyList?.map((e) => e.toJson()).toList() ?? <dynamic>[],
    };
  }
}
