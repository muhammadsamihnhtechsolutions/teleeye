class ProfileResponseModel {
  String? status;
  String? message;
  Profile? profile;

  ProfileResponseModel({this.status, this.message, this.profile});

  ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final data = json['data'];
    Map<String, dynamic>? map;
    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) {
        map = first;
      }
    }
    profile = map != null ? Profile.fromJson(map) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.profile != null) {
      data['data'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  String? sId;
  String? phone;
  int? iV;
  String? createdAt;
  String? dateOfBirth;
  String? dialCode;
  List<String>? favoriteDoctors;
  String? gender;
  bool? isVerified;
  String? name;
  Null parent;
  String? patientType;
  String? photo;
  String? relation;
  String? status;
  String? updatedAt;
  String? weight;
  String? email;

  Profile({
    this.sId,
    this.phone,
    this.iV,
    this.createdAt,
    this.dateOfBirth,
    this.dialCode,
    this.favoriteDoctors,
    this.gender,
    this.isVerified,
    this.name,
    this.parent,
    this.patientType,
    this.photo,
    this.relation,
    this.status,
    this.updatedAt,
    this.email,
    this.weight,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    phone = json['phone'];
    email = json['email'] != null ? "${json['email']}" : "";
    iV = json['__v'];
    createdAt = json['createdAt'];
    dateOfBirth = json['dateOfBirth'];
    dialCode = json['dialCode'];
    favoriteDoctors = json['favoriteDoctors'].cast<String>();
    gender = json['gender'];
    isVerified = json['isVerified'];
    name = json['name'];
    parent = json['parent'];
    patientType = json['patientType'];
    photo = json['photo'];
    relation = json['relation'];
    status = json['status'];
    updatedAt = json['updatedAt'];
    weight = json['weight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['phone'] = this.phone;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['dateOfBirth'] = this.dateOfBirth;
    data['dialCode'] = this.dialCode;
    data['favoriteDoctors'] = this.favoriteDoctors;
    data['gender'] = this.gender;
    data['isVerified'] = this.isVerified;
    data['name'] = this.name;
    data['parent'] = this.parent;
    data['patientType'] = this.patientType;
    data['photo'] = this.photo;
    data['relation'] = this.relation;
    data['status'] = this.status;
    data['updatedAt'] = this.updatedAt;
    data['weight'] = this.weight;
    data['email'] = this.email;
    return data;
  }
}
