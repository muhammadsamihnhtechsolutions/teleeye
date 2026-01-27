import 'dart:convert';
import 'dart:developer' as developer;
import 'package:eye_buddy/core/models/common_api_response_model.dart';
import 'package:eye_buddy/core/services/api/model/appointment_doctor_model.dart';
import 'package:eye_buddy/core/services/api/model/banner_response_model.dart';
import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/specialties_response_model.dart';
import 'package:eye_buddy/core/services/api/model/get_doctor_rating_model.dart';
import 'package:eye_buddy/core/services/api/model/init_payment_response_model.dart';
import 'package:eye_buddy/core/services/api/model/loginModels.dart';
import 'package:eye_buddy/core/services/api/model/notification_response_model.dart';
import 'package:eye_buddy/core/services/api/model/patient_list_model.dart';
import 'package:eye_buddy/core/services/api/model/profile_reponse_model.dart';
import 'package:eye_buddy/core/services/api/model/prescription_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/medication_tracker_model.dart';
import 'package:eye_buddy/core/services/api/model/test_result_response_model.dart';
import 'package:eye_buddy/core/services/api/model/app_test_result_response_model.dart';
import 'package:eye_buddy/core/services/api/model/verifyOtpModel.dart';
import 'package:eye_buddy/core/services/api/model/promo_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/apply_promo_response_model.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/api/service/api_service.dart';
import 'package:eye_buddy/core/services/utils/keys/token_keys.dart';
import 'package:flutter/foundation.dart'; // For compute
import 'package:shared_preferences/shared_preferences.dart';

void log(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(message, name: 'ApiRepo', error: error, stackTrace: stackTrace);
}

LoginApiResponseModel _parseLoginApiResponseModel(Map<String, dynamic> map) {
  return LoginApiResponseModel.fromMap(map);
}

ProfileResponseModel _parseProfileResponseModel(Map<String, dynamic> map) {
  return ProfileResponseModel.fromJson(map);
}

class ApiRepo {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _convertJsonForMedicationTracker(
    Map<String, dynamic> jsonData,
  ) {
    final outputList = <Map<String, dynamic>>[];

    for (final day in ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri']) {
      final enabled = jsonData[day] == true;
      if (!enabled) continue;

      final times = (jsonData['time'] as List?) ?? const [];
      for (final t in times) {
        outputList.add({
          'title': jsonData['title'],
          'day': day,
          'description': jsonData['description'],
          'time': t,
        });
      }
    }

    return outputList;
  }

  /// --------------------------------------------
  /// PROMOS - LIST
  /// --------------------------------------------
  Future<PromoResponseModel> getPromos() async {
    try {
      final response =
          await _apiService.getGetResponse(ApiConstants.patientPromos)
              as Map<String, dynamic>;
      return PromoResponseModel.fromJson(response);
    } catch (err) {
      log('Get promos error: $err');
      return PromoResponseModel(status: 'error', message: 'An error occurred');
    }
  }

  /// --------------------------------------------
  /// PROMOS - APPLY
  /// parameters: { code, appointment }
  /// --------------------------------------------
  Future<ApplyPromo> applyPromoCode(Map<String, String> parameters) async {
    try {
      final response =
          await _apiService.getPostResponse(
                ApiConstants.applyPromoCode,
                parameters,
              )
              as Map<String, dynamic>;
      return ApplyPromo.fromJson(response);
    } catch (err) {
      log('Apply promo error: $err');
      return ApplyPromo(status: 'error', message: 'An error occurred');
    }
  }

  //get medicines
  Future<MedicationTrackerApiResponse> getMedications() async {
    try {
      final resp =
          await _apiService.getGetResponse(
                '${ApiConstants.baseUrl}/api/patient/medicineTracker',
              )
              as Map<String, dynamic>;

      // Cache raw response list (used for delete-by-title because backend stores
      // one entry per day+time and each has its own _id).
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawList = resp['data'];
        if (rawList is List) {
          await prefs.setString('getMedicationListJson', jsonEncode(rawList));
        }
      } catch (_) {
        // Ignore caching errors
      }

      return MedicationTrackerApiResponse.fromMap(resp);
    } catch (e) {
      return MedicationTrackerApiResponse(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  //add medicines
  Future<UpdateMedicationApiResponse> addMedication({
    required Medication medication,
  }) async {
    try {
      final data = _convertJsonForMedicationTracker(medication.toMap());
      UpdateMedicationApiResponse? apiResponse;
      for (final element in data) {
        apiResponse = UpdateMedicationApiResponse.fromMap(
          await _apiService.getPostResponse(
                '${ApiConstants.baseUrl}/api/patient/medicineTracker',
                element,
              )
              as Map<String, dynamic>,
        );
      }
      return apiResponse ??
          UpdateMedicationApiResponse(
            status: 'error',
            message: 'An error occurred',
          );
    } catch (e) {
      return UpdateMedicationApiResponse(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  //update medicines
  Future<UpdateMedicationApiResponse> updateMedication({
    required Medication medication,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString('getMedicationListJson');
      final decoded = jsonDecode(rawJson ?? '[]');
      final rawList = (decoded is List)
          ? decoded
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];

      final originalTitle = (medication.originalTitle ?? medication.title ?? '')
          .trim();
      final currentTitle = (medication.title ?? '').trim();
      if (originalTitle.isEmpty || currentTitle.isEmpty) {
        return UpdateMedicationApiResponse(
          status: 'error',
          message: 'An error occurred',
        );
      }

      final existingSlots = rawList
          .where((e) => (e['title']?.toString() ?? '').trim() == originalTitle)
          .toList();

      final desiredDays = <String>{};
      if (medication.sat == true) desiredDays.add('sat');
      if (medication.sun == true) desiredDays.add('sun');
      if (medication.mon == true) desiredDays.add('mon');
      if (medication.tue == true) desiredDays.add('tue');
      if (medication.wed == true) desiredDays.add('wed');
      if (medication.thu == true) desiredDays.add('thu');
      if (medication.fri == true) desiredDays.add('fri');

      final desiredTimes = medication.time
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();

      final desiredKeys = <String>{};
      for (final d in desiredDays) {
        for (final t in desiredTimes) {
          desiredKeys.add('$d|$t');
        }
      }

      final existingKeyToId = <String, String>{};
      for (final e in existingSlots) {
        final id = (e['_id'] ?? e['id'] ?? '').toString().trim();
        final day = (e['day'] ?? '').toString().trim();
        final time = (e['time'] ?? '').toString().trim();
        if (id.isEmpty || day.isEmpty || time.isEmpty) continue;
        existingKeyToId['$day|$time'] = id;
      }

      UpdateMedicationApiResponse? last;

      for (final key in desiredKeys) {
        final parts = key.split('|');
        if (parts.length != 2) continue;
        final day = parts[0];
        final time = parts[1];

        final payload = <String, dynamic>{
          'title': currentTitle,
          'day': day,
          'description': (medication.description ?? '').toString(),
          'time': time,
        };

        final existingId = existingKeyToId[key];
        if (existingId != null && existingId.isNotEmpty) {
          payload['id'] = existingId;
          last = UpdateMedicationApiResponse.fromMap(
            await _apiService.getPatchResponse(
                  '${ApiConstants.baseUrl}/api/patient/medicineTracker',
                  payload,
                )
                as Map<String, dynamic>,
          );
        } else {
          last = UpdateMedicationApiResponse.fromMap(
            await _apiService.getPostResponse(
                  '${ApiConstants.baseUrl}/api/patient/medicineTracker',
                  payload,
                )
                as Map<String, dynamic>,
          );
        }
      }

      final toDelete = existingKeyToId.keys.where(
        (k) => !desiredKeys.contains(k),
      );
      for (final k in toDelete) {
        final id = existingKeyToId[k];
        if (id == null || id.isEmpty) continue;
        await _apiService.getDeleteResponse(
          '${ApiConstants.baseUrl}/api/patient/medicineTracker/$id',
        );
      }

      // Ensure next edit uses latest title as reference.
      medication.originalTitle = currentTitle;

      return last ??
          UpdateMedicationApiResponse(
            status: 'error',
            message: 'An error occurred',
          );
    } catch (e) {
      return UpdateMedicationApiResponse(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  // delete medicines
  Future<UpdateMedicationApiResponse> deleteMedication({
    required String id,
  }) async {
    try {
      final resp =
          await _apiService.getDeleteResponse(
                '${ApiConstants.baseUrl}/api/patient/medicineTracker/$id',
              )
              as Map<String, dynamic>;
      return UpdateMedicationApiResponse.fromMap(resp);
    } catch (e) {
      return UpdateMedicationApiResponse(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  /// --------------------------------------------
  /// LOGIN USER
  /// --------------------------------------------
  Future<LoginApiResponseModel> loginUser({
    required String phone,
    required String dialCode,
  }) async {
    try {
      final loginModel = LoginModel(dialCode: dialCode, phone: phone);

      final rawResponse = await _apiService.getPostResponse(
        '${ApiConstants.baseUrl}/api/patient/auth/request',
        loginModel.toMap(),
      );

      final Map<String, dynamic> response;
      if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      } else if (rawResponse is String) {
        final decoded = jsonDecode(rawResponse);
        if (decoded is Map<String, dynamic>) {
          response = decoded;
        } else {
          return LoginApiResponseModel(
            status: 'error',
            message: 'Unexpected response format',
          );
        }
      } else {
        return LoginApiResponseModel(
          status: 'error',
          message: 'Unexpected response format',
        );
      }

      if (kIsWeb) {
        return LoginApiResponseModel.fromMap(response);
      }

      return await compute(_parseLoginApiResponseModel, response);
    } catch (err) {
      log("Login error: $err");
      return LoginApiResponseModel(
        status: 'error',
        message: 'An error occurred during login',
      );
    }
  }

  Future<Doctor?> getDoctorById(String id) async {
    try {
      final data =
          await _apiService.getGetResponse(ApiConstants.getDoctorById + id)
              as Map<String, dynamic>;

      if (data['status'] == 'success') {
        return Doctor.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (err) {
      log('Get doctor by id error: $err');
      return null;
    }
  }

  //get favorite doctors
  Future<DoctorListResponseModel> getFavoritesDoctor() async {
    try {
      final response =
          await _apiService.getGetResponse(ApiConstants.patientDoctorFavorites)
              as Map<String, dynamic>;
      return DoctorListResponseModel.fromJson(response);
    } catch (err) {
      log('Get favorite doctors error: $err');
      return DoctorListResponseModel(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  //app test results
  Future<AppTestResultResponseModel> getAppTestResult() async {
    try {
      final response =
          await _apiService.getGetResponse(ApiConstants.appTestResult)
              as Map<String, dynamic>;
      return AppTestResultResponseModel.fromJson(response);
    } catch (err) {
      log('Get app test result error: $err');
      return AppTestResultResponseModel(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  //remove favorite doctor
  Future<CommonResponseModel> removeDoctorFromFavoritesDoctorList(
    String doctorId,
  ) async {
    try {
      final commonApiResponseModel = CommonResponseModel.fromJson(
        await _apiService.getDeleteResponse(
              ApiConstants.patientDoctorRemoveToFavorite + doctorId,
            )
            as Map<String, dynamic>,
      );
      return commonApiResponseModel;
    } catch (err) {
      log('Remove favorite doctor error: $err');
      return CommonResponseModel(status: 'error', message: 'An error occurred');
    }
  }

  //add favorite doctor
  Future<CommonResponseModel> addDoctorToFavoritesDoctorList(
    String doctorId,
  ) async {
    try {
      final commonApiResponseModel = CommonResponseModel.fromJson(
        await _apiService.getPostResponse(
              ApiConstants.patientDoctorAddToFavorite + doctorId,
              {},
            )
            as Map<String, dynamic>,
      );
      return commonApiResponseModel;
    } catch (err) {
      log('Add favorite doctor error: $err');
      return CommonResponseModel(status: 'error', message: 'An error occurred');
    }
  }

  /// --------------------------------------------
  /// VERIFY OTP
  /// --------------------------------------------
  Future<VerifyOtpApiResponse> verifyOtp({
    required String traceId,
    required String otpCode,
    required bool isForChangePhoneNumber,
  }) async {
    try {
      final verifyOtpModel = VerifyOtpModel(traceId: traceId, code: otpCode);

      final payload = verifyOtpModel.toMap();
      if (!isForChangePhoneNumber) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          if (voipDeviceToken.trim().isNotEmpty) {
            payload['voipToken'] = voipDeviceToken.trim();
          }
          if (apnsDeviceToken.trim().isNotEmpty) {
            payload['apnsToken'] = apnsDeviceToken.trim();
          }
        } else {
          payload['voipToken'] = '';
        }
      }
      log("Verify OTP Model: $payload");

      final verifyOtpApiResponse = VerifyOtpApiResponse.fromMap(
        await _apiService.getPostResponse(
              isForChangePhoneNumber
                  ? '${ApiConstants.baseUrl}/api/patient/changePhone/verify'
                  : '${ApiConstants.baseUrl}/api/patient/auth/verifyAuth',
              payload,
            )
            as Map<String, dynamic>,
      );
      return verifyOtpApiResponse;
    } catch (err) {
      log("Verify OTP error: $err");
      return VerifyOtpApiResponse(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  //get specialties list
  Future<SpecialtiesResponseModel> getSpecialtiesList() async {
    try {
      final response =
          await _apiService.getGetResponse(ApiConstants.specialtiesList)
              as Map<String, dynamic>;
      return SpecialtiesResponseModel.fromJson(response);
    } catch (err) {
      log('Get specialties list error: $err');
      return SpecialtiesResponseModel(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  /// --------------------------------------------
  /// RESEND OTP
  /// --------------------------------------------
  Future<void> resendOtp({required String traceId}) async {
    try {
      await _apiService.getPostResponse(
        '${ApiConstants.baseUrl}/api/common/resendOtp',
        {"traceId": traceId},
      );
    } catch (err) {
      log("Error resending OTP: $err");
      return;
    }
  }

  /// --------------------------------------------
  /// CHANGE PHONE NUMBER
  /// --------------------------------------------
  Future<LoginApiResponseModel> changePhoneNumber({
    required Map<String, dynamic> params,
  }) async {
    try {
      final response =
          await _apiService.getPostResponse(
                '${ApiConstants.baseUrl}/api/patient/changePhone/request',
                params,
              )
              as Map<String, dynamic>;

      final apiRes = await compute(
        (map) => LoginApiResponseModel.fromMap(map as Map<String, dynamic>),
        response,
      );

      return apiRes;
    } catch (err) {
      log("Change phone error: $err");
      return LoginApiResponseModel(
        status: 'error',
        message: 'An error occurred during phone number change',
      );
    }
  }

  /// --------------------------------------------
  /// GET PROFILE DATA
  /// --------------------------------------------
  Future<ProfileResponseModel> getProfileData() async {
    try {
      final rawResponse = await _apiService.getGetResponse(
        ApiConstants.profileMe,
      );

      dynamic normalizedResponse = rawResponse;
      if (rawResponse is String) {
        try {
          normalizedResponse = jsonDecode(rawResponse);
        } catch (_) {
          return ProfileResponseModel(
            status: 'error',
            message: 'Invalid server response while fetching profile data',
          );
        }
      }

      Map<String, dynamic>? map;
      if (normalizedResponse is Map<String, dynamic>) {
        map = normalizedResponse;
      } else if (normalizedResponse is List && normalizedResponse.isNotEmpty) {
        final first = normalizedResponse.first;
        if (first is Map<String, dynamic>) {
          map = first;
        }
      }

      if (map == null) {
        log(
          'Get profile error: unexpected response type ${normalizedResponse.runtimeType}',
        );
        return ProfileResponseModel(
          status: 'error',
          message: 'Invalid server response while fetching profile data',
        );
      }

      final apiResponse = await compute(
        (m) => ProfileResponseModel.fromJson(m as Map<String, dynamic>),
        map,
      );

      return apiResponse;
    } catch (err) {
      log("Get profile error: $err");
      return ProfileResponseModel(
        status: 'error',
        message: 'An error occurred while fetching profile data',
      );
    }
  }

  /// --------------------------------------------
  /// UPDATE PROFILE DATA
  /// --------------------------------------------
  Future<ProfileResponseModel> updateProfileData(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final rawResponse = await _apiService.getPatchResponse(
        ApiConstants.profileUpdate,
        parameters,
      );

      Map<String, dynamic>? response;
      if (rawResponse is Map<String, dynamic>) {
        response = rawResponse;
      } else if (rawResponse is List && rawResponse.isNotEmpty) {
        final first = rawResponse.first;
        if (first is Map<String, dynamic>) {
          response = first;
        }
      }

      if (response == null) {
        log(
          'Update profile error: unexpected response type ${rawResponse.runtimeType}',
        );
        return ProfileResponseModel(
          status: 'error',
          message: 'Invalid server response while updating profile data',
        );
      }

      if (kIsWeb) {
        return ProfileResponseModel.fromJson(response);
      }

      return await compute(_parseProfileResponseModel, response);
    } catch (err) {
      log("Update profile error: $err");
      return ProfileResponseModel(
        status: 'error',
        message: 'An error occurred while updating profile data',
      );
    }
  }

  /// --------------------------------------------
  /// UPLOAD PROFILE IMAGE
  /// --------------------------------------------
  Future<ProfileResponseModel> uploadProfileImageInBase64(
    String imageAsBase64, {
    String fileExtension = 'jpg',
  }) async {
    try {
      final safeExt = fileExtension.trim().isEmpty
          ? 'jpg'
          : fileExtension.trim().replaceAll('.', '').toLowerCase();
      final rawResponse = await _apiService.getPostResponse(
        '${ApiConstants.baseUrl}/api/patient/profile/uploadProfilePhoto',
        {"base64String": imageAsBase64, "fileExtension": safeExt},
      );

      dynamic normalizedResponse = rawResponse;
      if (rawResponse is String) {
        try {
          normalizedResponse = jsonDecode(rawResponse);
        } catch (_) {
          final lower = rawResponse.toLowerCase();
          final isTooLarge =
              lower.contains('413') ||
              lower.contains('request entity too large') ||
              lower.contains('entity too large');
          if (isTooLarge) {
            return ProfileResponseModel(
              status: 'error',
              message:
                  'Image is too large. Please choose a smaller photo and try again.',
            );
          }
          return ProfileResponseModel(
            status: 'error',
            message: 'Invalid server response while uploading profile image',
          );
        }
      }

      Map<String, dynamic>? response;
      if (normalizedResponse is Map<String, dynamic>) {
        response = normalizedResponse;
      } else if (normalizedResponse is List && normalizedResponse.isNotEmpty) {
        final first = normalizedResponse.first;
        if (first is Map<String, dynamic>) {
          response = first;
        }
      }

      if (response == null) {
        log(
          "Upload profile image error: unexpected response type ${normalizedResponse.runtimeType}",
        );
        return ProfileResponseModel(
          status: 'error',
          message: 'Invalid server response while uploading profile image',
        );
      }

      if (kIsWeb) {
        return ProfileResponseModel.fromJson(response);
      }

      return await compute(_parseProfileResponseModel, response);
    } catch (err) {
      log("Upload profile image error: $err");
      return ProfileResponseModel(
        status: 'error',
        message: 'An error occurred while uploading profile image',
      );
    }
  }

  /// --------------------------------------------
  /// GET HOME BANNERS
  /// --------------------------------------------
  Future<BannerResponseModel> getHomeBanners() async {
    try {
      final response =
          await _apiService.getGetResponse(ApiConstants.homeBanners)
              as Map<String, dynamic>;

      final bannerResponse = await compute(
        (map) => BannerResponseModel.fromJson(map as Map<String, dynamic>),
        response,
      );

      return bannerResponse;
    } catch (err) {
      log("Get home banners error: $err");
      return BannerResponseModel(
        status: 'error',
        message: 'An error occurred while fetching banners',
        bannerList: [],
      );
    }
  }

  /// --------------------------------------------
  /// GET APPOINTMENTS
  /// --------------------------------------------
  Future<dynamic> getAppointments(String type, String? patientId) async {
    try {
      final safeType = type.trim();
      final safePatientId = (patientId ?? '').trim();
      final base = '${ApiConstants.baseUrl}/api/patient/appointment/list';
      final url = safePatientId.isEmpty
          ? '$base?type=$safeType&limit=500'
          : '$base?type=$safeType&patient=$safePatientId&limit=500';

      final dynamic response = await _apiService.getGetResponse(url);

      if (response is Map<String, dynamic>) {
        return response;
      }

      // Some environments may return a raw list for this endpoint.
      if (response is List) {
        return {
          'status': 'success',
          'message': '',
          'data': {'docs': response},
        };
      }

      return {
        'status': 'error',
        'message': 'Unexpected response while fetching appointments',
        'data': null,
      };
    } catch (err) {
      log("Get appointments error: $err");
      return {
        'status': 'error',
        'message': 'An error occurred while fetching appointments',
        'data': null,
      };
    }
  }

  /// --------------------------------------------
  /// PRESCRIPTIONS - LIST
  /// --------------------------------------------
  Future<PrescriptionListResponseModel> getPrescriptionList(
    Map<String, String> parameters,
  ) async {
    try {
      final apiResponse = PrescriptionListResponseModel.fromJson(
        await _apiService.getGetQueryParametersResponse(
              ApiConstants.patientPrescription,
              parameters,
            )
            as Map<String, dynamic>,
      );
      return apiResponse;
    } catch (err) {
      log("Get prescription list error: $err");
      return PrescriptionListResponseModel(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  /// --------------------------------------------
  /// PRESCRIPTIONS - UPLOAD
  /// --------------------------------------------
  Future<Map<String, dynamic>> uploadPatientPrescription(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final response =
          await _apiService.getPostResponse(
                ApiConstants.patientPrescriptionUpload,
                parameters,
              )
              as Map<String, dynamic>;
      return response;
    } catch (err) {
      log("Upload prescription error: $err");
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }

  /// --------------------------------------------
  /// PRESCRIPTIONS - UPDATE CLINICAL
  /// --------------------------------------------
  Future<CommonResponseModel> updateClinicalPrescription(
    dynamic parameters,
  ) async {
    try {
      final response =
          await _apiService.getPatchResponse(
                ApiConstants.updateClinicalPrescription,
                parameters,
              )
              as Map<String, dynamic>;

      return CommonResponseModel.fromJson(response);
    } catch (err) {
      log('Update clinical prescription error: $err');
      return CommonResponseModel(status: 'error', message: 'An error occurred');
    }
  }

  /// --------------------------------------------
  /// TEST RESULTS - CLINICAL (LIST)
  /// --------------------------------------------
  Future<TestResultResponseModel> getClinicalTestResultData() async {
    try {
      final response =
          await _apiService.getGetResponse(ApiConstants.clinicalTestResult)
              as Map<String, dynamic>;
      return TestResultResponseModel.fromJson(response);
    } catch (err) {
      log('Get clinical test results error: $err');
      return TestResultResponseModel(
        status: 'error',
        message: 'An error occurred',
        data: TestResultResponseData(docs: <TestResult>[]),
      );
    }
  }

  /// --------------------------------------------
  /// TEST RESULTS - CLINICAL (UPLOAD)
  /// payload: { patient, title, attachment: {base64String, fileExtension} }
  /// --------------------------------------------
  Future<Map<String, dynamic>> uploadPatientClinicalResult(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final response =
          await _apiService.getPostResponse(
                ApiConstants.patientClinicalResultUpload,
                parameters,
              )
              as Map<String, dynamic>;
      return response;
    } catch (err) {
      log('Upload clinical result error: $err');
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }

  /// --------------------------------------------
  /// TEST RESULTS - DELETE (CLINICAL)
  /// BLoC uses: DELETE {ApiConstants.deleteTestResult}/{resultId}
  /// --------------------------------------------
  Future<CommonResponseModel> deleteTestResult({
    required String resultId,
  }) async {
    try {
      final response =
          await _apiService.getDeleteResponse(
                '${ApiConstants.deleteTestResult}/$resultId',
              )
              as Map<String, dynamic>;
      return CommonResponseModel.fromJson(response);
    } catch (err) {
      log('Delete test result error: $err');
      return CommonResponseModel(status: 'error', message: 'An error occurred');
    }
  }

  /// --------------------------------------------
  /// PRESCRIPTIONS - UPDATE PATIENT PRESCRIPTION
  /// --------------------------------------------
  Future<CommonResponseModel> updatePatientPrescription(
    dynamic parameters,
  ) async {
    try {
      final response =
          await _apiService.getPatchResponse(
                ApiConstants.updatePatientPrescriptionUpdate,
                parameters,
              )
              as Map<String, dynamic>;

      return CommonResponseModel.fromJson(response);
    } catch (err) {
      log('Update patient prescription error: $err');
      return CommonResponseModel(status: 'error', message: 'An error occurred');
    }
  }

  /// --------------------------------------------
  /// PRESCRIPTIONS - DELETE
  /// --------------------------------------------
  Future<Map<String, dynamic>> deletePrescriptionFromList(String id) async {
    try {
      final response =
          await _apiService.getDeleteResponse(
                ApiConstants.deletePatientPrescription + id,
              )
              as Map<String, dynamic>;
      return response;
    } catch (err) {
      log('Delete prescription error: $err');
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }

  /// --------------------------------------------
  /// DOCTORS - LIST
  /// --------------------------------------------
  Future<DoctorListResponseModel> getDoctorList(
    Map<String, String> parameters,
  ) async {
    try {
      final response =
          await _apiService.getGetQueryParametersResponse(
                ApiConstants.patientDoctor,
                parameters,
              )
              as Map<String, dynamic>;

      return DoctorListResponseModel.fromJson(response);
    } catch (err) {
      log('Get doctor list error: $err');
      return DoctorListResponseModel(
        status: 'error',
        message: 'An error occurred while fetching doctors',
      );
    }
  }

  /// --------------------------------------------
  /// PATIENTS - GET MY PATIENT LIST
  /// --------------------------------------------
  Future<GetPatientListApiResponse> getMyPatientList() async {
    try {
      final response =
          await _apiService.getGetResponse(
                '${ApiConstants.baseUrl}/api/patient/myPatients',
              )
              as Map<String, dynamic>;

      return GetPatientListApiResponse.fromMap(response);
    } catch (err) {
      log('Get my patient list error: $err');
      return GetPatientListApiResponse(
        status: 'error',
        message: 'An error occurred while fetching patients',
      );
    }
  }

  /// --------------------------------------------
  /// PATIENTS - SAVE MY PATIENT
  /// --------------------------------------------
  Future<GetPatientListApiResponse> saveMyPatient({
    required Map<String, dynamic> params,
  }) async {
    try {
      final response =
          await _apiService.getPostResponse(
                '${ApiConstants.baseUrl}/api/patient/myPatients',
                params,
              )
              as Map<String, dynamic>;

      return GetPatientListApiResponse.fromMap(response);
    } catch (err) {
      log('Save my patient error: $err');
      return GetPatientListApiResponse(
        status: 'error',
        message: 'An error occurred while saving patient',
      );
    }
  }

  /// --------------------------------------------
  /// APPOINTMENTS - SAVE APPOINTMENT
  /// --------------------------------------------
  Future<SaveAppointmentApiResponse> saveAppointments(
    Map<String, dynamic> params,
  ) async {
    try {
      final response =
          await _apiService.getPostResponse(
                '${ApiConstants.baseUrl}/api/patient/appointment/init',
                params,
              )
              as Map<String, dynamic>;

      return SaveAppointmentApiResponse.fromMap(response);
    } catch (err) {
      log('Save appointment error: $err');
      return SaveAppointmentApiResponse(
        status: 'error',
        message: 'An error occurred while saving appointment',
      );
    }
  }

  /// --------------------------------------------
  /// PAYMENTS - INITIATE PAYMENT
  /// --------------------------------------------
  Future<InitPaymentApiResponseModel> initiatePayment(
    Map<String, dynamic> params,
  ) async {
    try {
      final response =
          await _apiService.getPostResponse(
                '${ApiConstants.baseUrl}/api/patient/appointment/initiatePayment',
                params,
              )
              as Map<String, dynamic>;

      return InitPaymentApiResponseModel.fromJson(response);
    } catch (err) {
      log('Initiate payment error: $err');
      return InitPaymentApiResponseModel(
        status: 'error',
        message: 'An error occurred while initiating payment',
      );
    }
  }

  Future<NotificationResponseModel> getNotificationList(
    Map<String, String> parameters,
  ) async {
    try {
      final apiResponse = NotificationResponseModel.fromJson(
        await _apiService.getGetResponse(ApiConstants.notificationList)
            as Map<String, dynamic>,
      );
      return apiResponse;
    } catch (err) {
      return NotificationResponseModel(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  Future<GetDoctorRatingModel> getDoctorRating(String doctorId) async {
    try {
      final response =
          await _apiService.getGetResponse(
                ApiConstants.getDoctorRating + doctorId,
              )
              as Map<String, dynamic>;
      return GetDoctorRatingModel.fromJson(response);
    } catch (err) {
      log('Get doctor rating error: $err');
      return const GetDoctorRatingModel(
        status: 'error',
        message: 'An error occurred',
      );
    }
  }

  Future<CommonResponseModel> submitRating(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final response =
          await _apiService.getPostResponse(
                ApiConstants.submitRating,
                parameters,
              )
              as Map<String, dynamic>;
      return CommonResponseModel.fromJson(response);
    } catch (err) {
      log('Submit rating error: $err');
      return CommonResponseModel(status: 'error', message: 'An error occurred');
    }
  }

  Future<void> updateVisualAcuityTestResults({
    required String patientId,
    required String leftEyeScore,
    required String rightEyeScore,
  }) async {
    try {
      final existing = await getAppTestResult();

      final existingNearLeft = existing.appTestData?.nearVision?.left?.os
          ?.toString();
      final existingNearRight = existing.appTestData?.nearVision?.right?.od
          ?.toString();
      final existingColorLeft = existing.appTestData?.colorVision?.left
          ?.toString();
      final existingColorRight = existing.appTestData?.colorVision?.right
          ?.toString();
      final existingAmdLeft = existing.appTestData?.amdVision?.left?.toString();
      final existingAmdRight = existing.appTestData?.amdVision?.right
          ?.toString();

      await _apiService.getPostResponse(
        ApiConstants.updateVisualAcuityTestResults,
        {
          'patient': patientId,
          'data': {
            'visualAcuity': {
              'left': {'os': leftEyeScore},
              'right': {'od': rightEyeScore},
            },
            'colorVision': {
              'left':
                  (existingColorLeft != null && existingColorLeft.isNotEmpty)
                  ? existingColorLeft
                  : '--',
              'right':
                  (existingColorRight != null && existingColorRight.isNotEmpty)
                  ? existingColorRight
                  : '--',
            },
            'nearVision': {
              'left': {
                'os': (existingNearLeft != null && existingNearLeft.isNotEmpty)
                    ? existingNearLeft
                    : '--',
              },
              'right': {
                'od':
                    (existingNearRight != null && existingNearRight.isNotEmpty)
                    ? existingNearRight
                    : '--',
              },
            },
            'amdVision': {
              'left': (existingAmdLeft != null && existingAmdLeft.isNotEmpty)
                  ? existingAmdLeft
                  : '--',
              'right': (existingAmdRight != null && existingAmdRight.isNotEmpty)
                  ? existingAmdRight
                  : '--',
            },
          },
        },
      );
    } catch (err) {
      log('updateVisualAcuityTestResults error: $err');
    }
  }

  Future<void> updateNearVisionTestResults({
    required String patientId,
    required int leftEyeCounter,
    required int rightEyeCounter,
    required String leftVisualAcuityScore,
    required String rightVisualAcuityScore,
  }) async {
    try {
      final existing = await getAppTestResult();

      bool isPlaceholder(String? v) {
        final t = (v ?? '').trim();
        return t.isEmpty || t == '--' || t == '0/0' || t == '0/23';
      }

      final existingColorLeft = existing.appTestData?.colorVision?.left
          ?.toString();
      final existingColorRight = existing.appTestData?.colorVision?.right
          ?.toString();
      final existingAmdLeft = existing.appTestData?.amdVision?.left?.toString();
      final existingAmdRight = existing.appTestData?.amdVision?.right
          ?.toString();

      final existingVisualLeft = existing.appTestData?.visualAcuity?.left?.os
          ?.toString();
      final existingVisualRight = existing.appTestData?.visualAcuity?.right?.od
          ?.toString();

      final existingNearLeft = existing.appTestData?.nearVision?.left?.os
          ?.toString();
      final existingNearRight = existing.appTestData?.nearVision?.right?.od
          ?.toString();

      String resolveNear(int counter, String? existingValue) {
        if (counter > 0) return '$counter/23';
        if (!isPlaceholder(existingValue)) return (existingValue ?? '').trim();
        return '--';
      }

      final resolvedNearLeft = resolveNear(leftEyeCounter, existingNearLeft);
      final resolvedNearRight = resolveNear(rightEyeCounter, existingNearRight);

      await _apiService.getPostResponse(
        ApiConstants.updateVisualAcuityTestResults,
        {
          'patient': patientId,
          'data': {
            'nearVision': {
              'left': {'os': resolvedNearLeft},
              'right': {'od': resolvedNearRight},
            },
            'visualAcuity': {
              'left': {
                'os': leftVisualAcuityScore.isNotEmpty
                    ? leftVisualAcuityScore
                    : ((existingVisualLeft != null &&
                              existingVisualLeft.isNotEmpty)
                          ? existingVisualLeft
                          : '--'),
              },
              'right': {
                'od': rightVisualAcuityScore.isNotEmpty
                    ? rightVisualAcuityScore
                    : ((existingVisualRight != null &&
                              existingVisualRight.isNotEmpty)
                          ? existingVisualRight
                          : '--'),
              },
            },
            'colorVision': {
              'left':
                  (existingColorLeft != null && existingColorLeft.isNotEmpty)
                  ? existingColorLeft
                  : '--',
              'right':
                  (existingColorRight != null && existingColorRight.isNotEmpty)
                  ? existingColorRight
                  : '--',
            },
            'amdVision': {
              'left': (existingAmdLeft != null && existingAmdLeft.isNotEmpty)
                  ? existingAmdLeft
                  : '--',
              'right': (existingAmdRight != null && existingAmdRight.isNotEmpty)
                  ? existingAmdRight
                  : '--',
            },
          },
        },
      );
    } catch (err) {
      log('updateNearVisionTestResults error: $err');
    }
  }

  Future<void> updateColorVisionTestResults({
    required String patientId,
    required String leftResult,
    required String rightResult,
    required String leftVisualAcuityScore,
    required String rightVisualAcuityScore,
    required String leftNearVisionResult,
    required String rightNearVisionResult,
  }) async {
    try {
      final existing = await getAppTestResult();

      bool isPlaceholder(String v) {
        final t = v.trim();
        if (t.isEmpty) return true;
        if (t == '--') return true;
        if (t == '0/0') return true;
        if (t == '0/23') return true;
        return false;
      }

      final existingAmdLeft = existing.appTestData?.amdVision?.left?.toString();
      final existingAmdRight = existing.appTestData?.amdVision?.right
          ?.toString();

      final existingNearLeft = existing.appTestData?.nearVision?.left?.os
          ?.toString();
      final existingNearRight = existing.appTestData?.nearVision?.right?.od
          ?.toString();

      final existingVisualLeft = existing.appTestData?.visualAcuity?.left?.os
          ?.toString();
      final existingVisualRight = existing.appTestData?.visualAcuity?.right?.od
          ?.toString();

      String resolveValue(String incoming, String? existingValue) {
        if (!isPlaceholder(incoming)) return incoming.trim();
        final e = (existingValue ?? '').trim();
        if (e.isNotEmpty && !isPlaceholder(e)) return e;
        return '--';
      }

      final resolvedNearLeft = resolveValue(
        leftNearVisionResult,
        existingNearLeft,
      );
      final resolvedNearRight = resolveValue(
        rightNearVisionResult,
        existingNearRight,
      );
      final resolvedVisualLeft = resolveValue(
        leftVisualAcuityScore,
        existingVisualLeft,
      );
      final resolvedVisualRight = resolveValue(
        rightVisualAcuityScore,
        existingVisualRight,
      );
      final resolvedAmdLeft = resolveValue('--', existingAmdLeft);
      final resolvedAmdRight = resolveValue('--', existingAmdRight);

      final data = <String, dynamic>{
        'colorVision': {'left': leftResult, 'right': rightResult},
      };

      final nearVision = <String, dynamic>{};
      if (resolvedNearLeft != null) {
        nearVision['left'] = {'os': resolvedNearLeft};
      }
      if (resolvedNearRight != null) {
        nearVision['right'] = {'od': resolvedNearRight};
      }
      if (nearVision.isNotEmpty) {
        data['nearVision'] = nearVision;
      }

      final visualAcuity = <String, dynamic>{};
      if (resolvedVisualLeft != null) {
        visualAcuity['left'] = {'os': resolvedVisualLeft};
      }
      if (resolvedVisualRight != null) {
        visualAcuity['right'] = {'od': resolvedVisualRight};
      }
      if (visualAcuity.isNotEmpty) {
        data['visualAcuity'] = visualAcuity;
      }

      final amdVision = <String, dynamic>{};
      if (resolvedAmdLeft != null) {
        amdVision['left'] = resolvedAmdLeft;
      }
      if (resolvedAmdRight != null) {
        amdVision['right'] = resolvedAmdRight;
      }
      if (amdVision.isNotEmpty) {
        data['amdVision'] = amdVision;
      }

      await _apiService.getPostResponse(
        ApiConstants.updateVisualAcuityTestResults,
        {'patient': patientId, 'data': data},
      );
    } catch (err) {
      log('updateColorVisionTestResults error: $err');
    }
  }

  Future<void> updateAmdTestResults({
    required String patientId,
    required String leftResult,
    required String rightResult,
    required String leftVisualAcuityScore,
    required String rightVisualAcuityScore,
    required String leftNearVisionResult,
    required String rightNearVisionResult,
    required String colorVisionLeft,
    required String colorVisionRight,
  }) async {
    try {
      final existing = await getAppTestResult();

      bool isPlaceholder(String v) {
        final t = v.trim();
        if (t.isEmpty) return true;
        if (t == '--') return true;
        if (t == '0/0') return true;
        if (t == '0/23') return true;
        return false;
      }

      final existingNearLeft = existing.appTestData?.nearVision?.left?.os
          ?.toString();
      final existingNearRight = existing.appTestData?.nearVision?.right?.od
          ?.toString();

      final existingVisualLeft = existing.appTestData?.visualAcuity?.left?.os
          ?.toString();
      final existingVisualRight = existing.appTestData?.visualAcuity?.right?.od
          ?.toString();

      final existingColorLeft = existing.appTestData?.colorVision?.left
          ?.toString();
      final existingColorRight = existing.appTestData?.colorVision?.right
          ?.toString();

      String resolveValue(String incoming, String? existingValue) {
        if (!isPlaceholder(incoming)) return incoming.trim();
        final e = (existingValue ?? '').trim();
        if (e.isNotEmpty && !isPlaceholder(e)) return e;
        return '--';
      }

      final resolvedNearLeft = resolveValue(
        leftNearVisionResult,
        existingNearLeft,
      );
      final resolvedNearRight = resolveValue(
        rightNearVisionResult,
        existingNearRight,
      );
      final resolvedVisualLeft = resolveValue(
        leftVisualAcuityScore,
        existingVisualLeft,
      );
      final resolvedVisualRight = resolveValue(
        rightVisualAcuityScore,
        existingVisualRight,
      );

      final resolvedColorLeft = resolveValue(
        colorVisionLeft,
        existingColorLeft,
      );
      final resolvedColorRight = resolveValue(
        colorVisionRight,
        existingColorRight,
      );

      final data = <String, dynamic>{
        'amdVision': {'left': leftResult, 'right': rightResult},
      };

      final colorVision = <String, dynamic>{};
      if (resolvedColorLeft != null) colorVision['left'] = resolvedColorLeft;
      if (resolvedColorRight != null) colorVision['right'] = resolvedColorRight;
      if (colorVision.isNotEmpty) data['colorVision'] = colorVision;

      final nearVision = <String, dynamic>{};
      if (resolvedNearLeft != null)
        nearVision['left'] = {'os': resolvedNearLeft};
      if (resolvedNearRight != null) {
        nearVision['right'] = {'od': resolvedNearRight};
      }
      if (nearVision.isNotEmpty) data['nearVision'] = nearVision;

      final visualAcuity = <String, dynamic>{};
      if (resolvedVisualLeft != null) {
        visualAcuity['left'] = {'os': resolvedVisualLeft};
      }
      if (resolvedVisualRight != null) {
        visualAcuity['right'] = {'od': resolvedVisualRight};
      }
      if (visualAcuity.isNotEmpty) data['visualAcuity'] = visualAcuity;

      await _apiService.getPostResponse(
        ApiConstants.updateVisualAcuityTestResults,
        {'patient': patientId, 'data': data},
      );
    } catch (err) {
      log('updateAmdTestResults error: $err');
    }
  }

  Future<CommonResponseModel> sendEyeTestResultsToDoctor({
    required String doctorId,
    required String patientId,
    required String message,
    required Map<String, dynamic> results,
  }) async {
    try {
      final parameters = {
        'type': 'new',
        'content': message,
        'contentType': 'text',
        'subject': 'Eye test results',
        'doctor': doctorId,
        'patient': patientId,
        'data': results,
      };
      final dynamic raw = await _apiService.getPostResponse(
        '${ApiConstants.baseUrl}/api/patient/support/submit',
        parameters,
      );

      if (raw is Map<String, dynamic>) {
        if (raw['error'] == true) {
          return CommonResponseModel(
            status: 'error',
            message: raw['message']?.toString() ?? 'An error occurred',
          );
        }
        final model = CommonResponseModel.fromJson(raw);
        if ((model.status ?? '').isEmpty &&
            raw.containsKey('status') == false) {
          return CommonResponseModel(
            status: 'error',
            message: raw['message']?.toString() ?? 'An error occurred',
          );
        }
        return model;
      }

      return CommonResponseModel(status: 'error', message: 'An error occurred');
    } catch (e, s) {
      log('sendEyeTestResultsToDoctor error: $e', stackTrace: s);
      return CommonResponseModel(status: 'error', message: 'An error occurred');
    }
  }

  /// --------------------------------------------
  /// SUPPORT - SUBMIT MESSAGE (NEW/EXISTING)
  /// --------------------------------------------
  Future<Map<String, dynamic>> submitSupportMessage({
    required String type,
    String? supportId,
    required String content,
    required String contentType,
  }) async {
    try {
      final payload = <String, dynamic>{
        'type': type,
        'content': content,
        'contentType': contentType,
      };
      if (supportId != null && supportId.trim().isNotEmpty) {
        payload['supportId'] = supportId.trim();
      }
      final raw = await _apiService.getPostResponse(
        ApiConstants.supportSubmit,
        payload,
      );
      if (kDebugMode) {
        log('Support submit raw response: $raw');
      }
      return (raw is Map<String, dynamic>)
          ? raw
          : <String, dynamic>{'status': 'error', 'message': 'Invalid response'};
    } catch (err) {
      log('Submit support message error: $err');
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }

  /// --------------------------------------------
  /// SUPPORT - LIST THREADS
  /// --------------------------------------------
  Future<Map<String, dynamic>> getSupportList() async {
    try {
      final raw = await _apiService.getGetResponse(ApiConstants.supportList);
      if (kDebugMode) {
        log('Support list raw response: $raw');
      }
      return (raw is Map<String, dynamic>)
          ? raw
          : <String, dynamic>{'status': 'error', 'message': 'Invalid response'};
    } catch (err) {
      log('Get support list error: $err');
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }

  /// --------------------------------------------
  /// SUPPORT - MESSAGES
  /// --------------------------------------------
  Future<Map<String, dynamic>> getSupportMessages({
    required String supportId,
  }) async {
    try {
      final raw = await _apiService.getGetResponse(
        '${ApiConstants.supportMessages}${supportId.trim()}',
      );
      if (kDebugMode) {
        log('Support messages raw response: $raw');
      }
      return (raw is Map<String, dynamic>)
          ? raw
          : <String, dynamic>{'status': 'error', 'message': 'Invalid response'};
    } catch (err) {
      log('Get support messages error: $err');
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }
}
