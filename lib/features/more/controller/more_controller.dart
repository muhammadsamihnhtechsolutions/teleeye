import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:eye_buddy/core/services/api/model/appointment_doctor_model.dart'
    as appt;
import 'package:eye_buddy/core/services/api/model/app_test_result_response_model.dart';
import 'package:eye_buddy/core/services/api/model/apply_promo_response_model.dart';
import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/medication_tracker_model.dart';
import 'package:eye_buddy/core/services/api/model/patient_list_model.dart';
import 'package:eye_buddy/core/services/api/model/prescription_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/promo_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/test_result_response_model.dart'
    as tr;
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/features/reason_for_visit/controller/reason_for_visit_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrescriptionItem {
  PrescriptionItem({
    required this.title,
    required this.doctorName,
    required this.dateLabel,
    this.status = 'Pending',
  });

  final String title;
  final String doctorName;
  final String dateLabel;
  final String status;
}

class TestResultItem {
  TestResultItem({
    required this.title,
    required this.type,
    required this.dateLabel,
  });

  final String title;
  final String type;
  final String dateLabel;
}

class DoctorItem {
  DoctorItem({
    required this.name,
    required this.specialty,
    required this.hospital,
  });

  final String name;
  final String specialty;
  final String hospital;
}

class TransactionItem {
  TransactionItem({
    required this.id,
    required this.amountLabel,
    required this.status,
    required this.dateLabel,
  });

  final String id;
  final String amountLabel;
  final String status;
  final String dateLabel;
}

class PromoItem {
  PromoItem({
    required this.code,
    required this.description,
    this.discountLabel = '',
    bool isApplied = false,
  }) : isApplied = isApplied.obs;

  final String code;
  final String description;
  final String discountLabel;
  final RxBool isApplied;
}

class SupportThread {
  SupportThread({
    required this.id,
    required this.subject,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String subject;
  final String status;
  final DateTime updatedAt;
}

class SupportMessage {
  SupportMessage({
    required this.id,
    required this.message,
    required this.fromUser,
    required this.sentAt,
    required this.contentType,
  });

  final String id;
  final String message;
  final bool fromUser;
  final DateTime sentAt;
  final String contentType;
}

class MoreController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();
  final Dio _dio = Dio();

  final selectedPrescriptionFile = Rx<XFile?>(null);
  final isUploadingPrescription = false.obs;
  final isLoadingPrescriptions = false.obs;
  final prescriptions = <PrescriptionItem>[].obs;
  final apiPrescriptions = <Prescription>[].obs;

  final selectedClinicalFile = Rx<XFile?>(null);
  final isUploadingClinicalResult = false.obs;
  final isLoadingClinicalResults = false.obs;
  final clinicalResultDocs = <tr.TestResult>[].obs;

  final isLoadingAppTestResults = false.obs;
  final appTestResultResponse = Rx<AppTestResultResponseModel?>(null);

  final isLoadingPatients = false.obs;
  final patients = <MyPatient>[].obs;
  final selectedPatient = Rx<MyPatient?>(null);

  final isLoadingTransactions = false.obs;
  final transactionAppointments = <appt.AppointmentData>[].obs;
  final transactionsHistoryResponse = Rx<appt.GetAppointmentApiResponse?>(null);

  final isLoadingPromos = false.obs;
  final promoResponse = Rx<PromoResponseModel?>(null);
  final apiPromos = <Promo>[].obs;

  final isLoadingFavoriteDoctors = false.obs;
  final favoriteDoctorsResponse = Rx<DoctorListResponseModel?>(null);
  final favoriteDoctors = <Doctor>[].obs;

  final isLoadingSupportList = false.obs;
  final isLoadingSupportMessages = false.obs;
  final isSendingSupportMessage = false.obs;
  final supportThreads = <SupportThread>[].obs;
  final supportMessages = <SupportMessage>[].obs;
  final activeSupportId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
    fetchPrescriptions();
    fetchClinicalResults();
    fetchAppTestResults();
    _loadPatientsFromStorage();
    fetchPatients();
    fetchPromos();
    fetchFavoriteDoctors();
  }

  Future<void> fetchAppTestResults() async {
    isLoadingAppTestResults.value = true;
    try {
      final resp = await _apiRepo.getAppTestResult();
      appTestResultResponse.value = resp;
    } catch (e, s) {
      log('MoreController: fetchAppTestResults error -> $e', stackTrace: s);
      appTestResultResponse.value = null;
    } finally {
      isLoadingAppTestResults.value = false;
    }
  }

  Future<void> fetchFavoriteDoctors() async {
    isLoadingFavoriteDoctors.value = true;
    try {
      final resp = await _apiRepo.getFavoritesDoctor();
      favoriteDoctorsResponse.value = resp;
      favoriteDoctors.assignAll(resp.doctorListResponseData?.doctorList ?? []);
    } catch (e, s) {
      log('MoreController: fetchFavoriteDoctors error -> $e', stackTrace: s);
      favoriteDoctorsResponse.value = null;
      favoriteDoctors.clear();
    } finally {
      isLoadingFavoriteDoctors.value = false;
    }
  }

  Future<bool> removeFavoriteDoctor(Doctor doctor) async {
    final id = (doctor.id ?? '').trim();
    if (id.isEmpty) return false;
    isLoadingFavoriteDoctors.value = true;
    try {
      final resp = await _apiRepo.removeDoctorFromFavoritesDoctorList(id);
      final ok = (resp.status ?? '').toLowerCase() == 'success';
      if (ok) {
        favoriteDoctors.removeWhere((d) => (d.id ?? '') == id);
      }
      return ok;
    } catch (e, s) {
      log('MoreController: removeFavoriteDoctor error -> $e', stackTrace: s);
      return false;
    } finally {
      isLoadingFavoriteDoctors.value = false;
    }
  }

  Future<void> fetchPromos() async {
    isLoadingPromos.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(getPromoKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          final cachedResp = PromoResponseModel.fromJson(decoded);
          promoResponse.value = cachedResp;
          apiPromos.assignAll(
            cachedResp.promoResponseData?.promoList ?? <Promo>[],
          );
        } catch (_) {
          // ignore
        }
      }

      final remote = await _apiRepo.getPromos();
      promoResponse.value = remote;
      apiPromos.assignAll(remote.promoResponseData?.promoList ?? <Promo>[]);
      await prefs.setString(getPromoKey, jsonEncode(remote.toJson()));
    } catch (e, s) {
      log('MoreController: fetchPromos error -> $e', stackTrace: s);
    } finally {
      isLoadingPromos.value = false;
    }
  }

  Future<ApplyPromo?> applyPromoToAppointment({
    required String code,
    required String appointmentId,
  }) async {
    final safeCode = code.trim();
    final safeAppointmentId = appointmentId.trim();
    if (safeCode.isEmpty || safeAppointmentId.isEmpty) return null;

    isLoadingPromos.value = true;
    try {
      final resp = await _apiRepo.applyPromoCode({
        'code': safeCode,
        'appointment': safeAppointmentId,
      });

      if (resp.status == 'success') {
        if (Get.isRegistered<ReasonForVisitController>()) {
          final reasonCtrl = Get.find<ReasonForVisitController>();
          await reasonCtrl.updateAppointmentWithPromoData(
            vat: resp.data?.vat ?? 0,
            grandTotal: resp.data?.grandTotal ?? 0,
            totalAmount: resp.data?.totalAmount ?? 0,
            discount: resp.data?.discount ?? resp.data?.usdDiscount,
            promoCode: resp.data?.promoCode,
          );
        }
        return resp;
      }

      return resp;
    } catch (e, s) {
      log('MoreController: applyPromoToAppointment error -> $e', stackTrace: s);
      return null;
    } finally {
      isLoadingPromos.value = false;
    }
  }

  Future<String> _resolvePatientIdForTransactions({String? patientId}) async {
    final fromArg = (patientId ?? '').trim();
    if (fromArg.isNotEmpty) return fromArg;

    final selected = (selectedPatient.value?.id ?? '').trim();
    if (selected.isNotEmpty) return selected;

    try {
      final profileCtrl = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());
      if (profileCtrl.profileData.value.profile == null) {
        await profileCtrl.getProfileData();
      }
      return (profileCtrl.profileData.value.profile?.sId ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  Future<void> fetchTransactionsHistory({String? patientId}) async {
    final resolvedPatientId = await _resolvePatientIdForTransactions(
      patientId: patientId,
    );
    if (resolvedPatientId.isEmpty) {
      transactionAppointments.clear();
      transactionsHistoryResponse.value = null;
      return;
    }

    isLoadingTransactions.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(getTransactionListKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          final cachedResp = appt.GetAppointmentApiResponse.fromJson(decoded);
          transactionsHistoryResponse.value = cachedResp;
          transactionAppointments.assignAll(
            cachedResp.appointmentList?.appointmentData ??
                <appt.AppointmentData>[],
          );
        } catch (_) {
          // ignore cache parse errors
        }
      }

      final resp = await _apiRepo.getAppointments('', resolvedPatientId);
      final parsed = appt.GetAppointmentApiResponse.fromJson(
        resp as Map<String, dynamic>,
      );

      transactionsHistoryResponse.value = parsed;
      transactionAppointments.assignAll(
        parsed.appointmentList?.appointmentData ?? <appt.AppointmentData>[],
      );

      await prefs.setString(getTransactionListKey, jsonEncode(parsed.toJson()));
    } catch (e) {
      log('MoreController: fetchTransactionsHistory error -> $e');
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Future<void> _loadPatientsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('my-patient-list');
      if (jsonStr == null) return;
      final apiResponse = GetPatientListApiResponse.fromJson(jsonStr);
      if (apiResponse.data != null) {
        patients.assignAll(apiResponse.data!);
        _ensureSelectedPatientIsValid();
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> fetchPatients() async {
    try {
      isLoadingPatients.value = true;
      final apiResponse = await _apiRepo.getMyPatientList();
      if (apiResponse.status == 'success' && apiResponse.data != null) {
        patients.assignAll(apiResponse.data!);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('my-patient-list', apiResponse.toJson());
        _ensureSelectedPatientIsValid();
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingPatients.value = false;
    }
  }

  void _ensureSelectedPatientIsValid() {
    if (patients.isEmpty) {
      selectedPatient.value = null;
      return;
    }

    final current = selectedPatient.value;
    if (current == null) {
      selectedPatient.value = patients.first;
      return;
    }

    final currentId = (current.id ?? '').trim();
    if (currentId.isEmpty) {
      selectedPatient.value = patients.first;
      return;
    }

    MyPatient? match;
    for (final p in patients) {
      if ((p.id ?? '').trim() == currentId) {
        match = p;
        break;
      }
    }
    selectedPatient.value = match ?? patients.first;
  }

  void setSelectedPatient(MyPatient? patient) {
    selectedPatient.value = patient;
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(languagePrefsKey);
      final code = (saved == 'bn' || saved == 'en')
          ? saved!
          : (Get.locale?.languageCode == 'bn' ? 'bn' : 'en');
      selectedLocaleCode.value = code;
    } catch (_) {
      selectedLocaleCode.value = Get.locale?.languageCode == 'bn' ? 'bn' : 'en';
    }
  }

  Future<void> fetchClinicalResults() async {
    try {
      isLoadingClinicalResults.value = true;
      final resp = await _apiRepo.getClinicalTestResultData();
      if (resp.status == 'success') {
        clinicalResultDocs.assignAll(resp.data?.docs ?? <tr.TestResult>[]);
      } else {
        clinicalResultDocs.clear();
      }
    } catch (_) {
      clinicalResultDocs.clear();
    } finally {
      isLoadingClinicalResults.value = false;
    }
  }

  Future<void> pickClinicalFile() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    if (file != null) {
      selectedClinicalFile.value = file;
      debugPrint('Selected clinical file: ${file.path}');
    }
  }

  Future<bool> uploadClinicalResult(String title, {String? patientId}) async {
    if (title.trim().isEmpty) return false;
    if (selectedClinicalFile.value == null) return false;

    final resolvedPatientId = (patientId != null && patientId.trim().isNotEmpty)
        ? patientId.trim()
        : selectedPatient.value?.id;
    final profileId =
        Get.find<ProfileController>().profileData.value.profile?.sId;

    isUploadingClinicalResult.value = true;
    try {
      final file = selectedClinicalFile.value!;
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final ext = p.extension(file.path).isNotEmpty
          ? p.extension(file.path)
          : '.jpg';

      final payload = {
        if (resolvedPatientId != null && resolvedPatientId.isNotEmpty)
          'patient': resolvedPatientId
        else if (profileId != null)
          'patient': profileId,
        'title': title.trim(),
        'attachment': {'base64String': base64Image, 'fileExtension': ext},
      };

      final response = await _apiRepo.uploadPatientClinicalResult(payload);
      if (response['status'] == 'success') {
        await fetchClinicalResults();
        selectedClinicalFile.value = null;
        return true;
      }
      return false;
    } finally {
      isUploadingClinicalResult.value = false;
    }
  }

  Future<bool> deleteClinicalTestResult(String id) async {
    if (id.trim().isEmpty) return false;
    try {
      isLoadingClinicalResults.value = true;
      final resp = await _apiRepo.deleteTestResult(resultId: id.trim());
      final ok = resp.status == 'success';
      await fetchClinicalResults();
      return ok;
    } finally {
      isLoadingClinicalResults.value = false;
    }
  }

  final favouriteDoctors = <DoctorItem>[
    DoctorItem(
      name: 'Dr. Tahira Islam',
      specialty: 'Retina specialist',
      hospital: 'BEH Dhaka',
    ),
    DoctorItem(
      name: 'Dr. Faisal Rahman',
      specialty: 'Cornea specialist',
      hospital: 'BEH Chittagong',
    ),
  ].obs;

  final transactions = <TransactionItem>[
    TransactionItem(
      id: '#INV-1045',
      amountLabel: '৳ 2,800',
      status: 'Paid',
      dateLabel: '27 Dec 2024',
    ),
    TransactionItem(
      id: '#INV-1031',
      amountLabel: '৳ 1,950',
      status: 'Refunded',
      dateLabel: '12 Dec 2024',
    ),
  ].obs;

  final promos = <PromoItem>[
    PromoItem(
      code: 'BEH50',
      description: '50% off on first consultation',
      discountLabel: 'Flat 50%',
    ),
    PromoItem(
      code: 'EYE10',
      description: '10% off on eye tests',
      discountLabel: '10% OFF',
    ),
  ].obs;

  final selectedLocaleCode = 'en'.obs;

  void removeFavourite(DoctorItem doctor) {
    favouriteDoctors.remove(doctor);
  }

  void addPrescription(PrescriptionItem item) {
    prescriptions.insert(0, item);
  }

  Future<void> pickPrescriptionFile() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    if (file != null) {
      selectedPrescriptionFile.value = file;
      debugPrint('Selected prescription file: ${file.path}');
    }
  }

  Future<bool> uploadPrescription(String title, {String? patientId}) async {
    if (title.trim().isEmpty) {
      debugPrint('Upload blocked: title is empty');
      return false;
    }
    if (selectedPrescriptionFile.value == null) {
      debugPrint('Upload blocked: no file selected');
      return false;
    }

    final resolvedPatientId = (patientId != null && patientId.trim().isNotEmpty)
        ? patientId.trim()
        : selectedPatient.value?.id;

    final profileId =
        Get.find<ProfileController>().profileData.value.profile?.sId;

    isUploadingPrescription.value = true;
    try {
      final file = selectedPrescriptionFile.value!;
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final ext = p.extension(file.path).isNotEmpty
          ? p.extension(file.path)
          : '.jpg';

      final payload = {
        if (resolvedPatientId != null && resolvedPatientId.isNotEmpty)
          'patient': resolvedPatientId
        else if (profileId != null)
          'patient': profileId,
        'title': title.trim(),
        'attachment': {'base64String': base64Image, 'fileExtension': ext},
      };

      log('Uploading prescription payload keys: ${payload.keys}');
      final response = await _apiRepo.uploadPatientPrescription(payload);
      log('Upload prescription response: $response');

      if (response['status'] == 'success') {
        await fetchPrescriptions(remoteOnly: true);
        selectedPrescriptionFile.value = null;
        return true;
      }
      return false;
    } catch (e, s) {
      log('Upload prescription error: $e', stackTrace: s);
      return false;
    } finally {
      isUploadingPrescription.value = false;
    }
  }

  void togglePromo(PromoItem promo) {
    promo.isApplied.toggle();
    promos.refresh();
  }

  Future<void> initSupport() async {
    await fetchSupportThreads(selectLatest: true);
    final id = activeSupportId.value.trim();
    if (id.isNotEmpty) {
      await fetchSupportMessages(id);
    } else {
      supportMessages.clear();
    }
  }

  Future<void> fetchSupportThreads({bool selectLatest = false}) async {
    isLoadingSupportList.value = true;
    try {
      final raw = await _apiRepo.getSupportList();
      if (kDebugMode) {
        log('Support list response: $raw');
      }
      final list = _extractList(raw);
      final threads = list
          .map(_mapSupportThread)
          .where((t) => t.id.isNotEmpty)
          .toList();
      threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      supportThreads.assignAll(threads);
      if (selectLatest && threads.isNotEmpty) {
        activeSupportId.value = threads.first.id;
        if (kDebugMode) {
          log('Support thread selected: ${activeSupportId.value}');
        }
      }
    } catch (e, s) {
      log('MoreController: fetchSupportThreads error -> $e', stackTrace: s);
      supportThreads.clear();
    } finally {
      isLoadingSupportList.value = false;
    }
  }

  Future<void> fetchSupportMessages(String supportId) async {
    final safeId = supportId.trim();
    if (safeId.isEmpty) return;
    isLoadingSupportMessages.value = true;
    try {
      final raw = await _apiRepo.getSupportMessages(supportId: safeId);
      if (kDebugMode) {
        log('Support messages response: $raw');
      }
      final list = _extractList(raw);
      final messages = list
          .map(_mapSupportMessage)
          .where((m) => m.message.isNotEmpty)
          .toList();
      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      if (messages.isNotEmpty || supportMessages.isEmpty) {
        supportMessages.assignAll(messages);
        if (kDebugMode) {
          log('Support messages loaded: ${messages.length}');
        }
      }
    } catch (e, s) {
      log('MoreController: fetchSupportMessages error -> $e', stackTrace: s);
    } finally {
      isLoadingSupportMessages.value = false;
    }
  }

  Future<void> sendSupportMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final existingId = activeSupportId.value.trim();
    final type = existingId.isEmpty ? 'new' : 'existing';

    isSendingSupportMessage.value = true;
    final optimistic = SupportMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      message: trimmed,
      fromUser: true,
      sentAt: DateTime.now(),
      contentType: 'text',
    );
    supportMessages.add(optimistic);
    try {
      final raw = await _apiRepo.submitSupportMessage(
        type: type,
        supportId: existingId.isEmpty ? null : existingId,
        content: trimmed,
        contentType: 'text',
      );
      if (kDebugMode) {
        log('Support submit response: $raw');
      }
      final newId = _extractSupportId(raw);
      if (newId.isNotEmpty && existingId.isEmpty) {
        activeSupportId.value = newId;
        if (kDebugMode) {
          log('Support thread set from submit: $newId');
        }
      }
      if (activeSupportId.value.isEmpty) {
        await fetchSupportThreads(selectLatest: true);
      }
      if (activeSupportId.value.isNotEmpty) {
        await fetchSupportMessages(activeSupportId.value);
      }
      await fetchSupportThreads(selectLatest: false);
    } catch (e, s) {
      log('MoreController: sendSupportMessage error -> $e', stackTrace: s);
      showToastMessage(message: 'Failed to send message');
    } finally {
      isSendingSupportMessage.value = false;
    }
  }

  void setLocale(String code) {
    final normalized = (code == 'bn') ? 'bn' : 'en';
    selectedLocaleCode.value = normalized;
    Get.updateLocale(Locale(normalized));
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(languagePrefsKey, normalized),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (raw is! Map) return <Map<String, dynamic>>[];

    dynamic data =
        raw['data'] ??
        raw['list'] ??
        raw['result'] ??
        raw['supportList'] ??
        raw['messageList'] ??
        raw['supports'] ??
        raw['messages'] ??
        raw['docs'];
    if (data is Map) {
      data =
          data['list'] ??
          data['supports'] ??
          data['messages'] ??
          data['supportList'] ??
          data['messageList'] ??
          data['docs'] ??
          data['items'] ??
          data['data'];
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  String _extractSupportId(Map<String, dynamic> raw) {
    final direct = (raw['supportId'] ?? raw['id'] ?? raw['_id'])
        ?.toString()
        .trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final data = raw['data'];
    if (data is Map) {
      final nested = (data['supportId'] ?? data['id'] ?? data['_id'])
          ?.toString()
          .trim();
      if (nested != null && nested.isNotEmpty) return nested;
      final support = data['support'];
      if (support is Map) {
        final sid = (support['id'] ?? support['_id'])?.toString().trim();
        if (sid != null && sid.isNotEmpty) return sid;
      }
    }
    return '';
  }

  SupportThread _mapSupportThread(Map<String, dynamic> map) {
    final id =
        (map['_id'] ?? map['id'] ?? map['supportId'] ?? '').toString().trim();
    final subject =
        (map['subject'] ?? map['title'] ?? map['type'] ?? 'Support')
            .toString();
    final status = (map['status'] ?? '').toString();
    final updatedAt = _parseDateTime(
      map['updatedAt'] ?? map['updated_at'] ?? map['createdAt'],
    );
    return SupportThread(
      id: id,
      subject: subject,
      status: status,
      updatedAt: updatedAt,
    );
  }

  SupportMessage _mapSupportMessage(Map<String, dynamic> map) {
    final id = (map['_id'] ?? map['id'] ?? '').toString().trim();
    final contentType =
        (map['contentType'] ?? map['content_type'] ?? 'text').toString();
    final content =
        (map['content'] ??
                map['message'] ??
                map['text'] ??
                map['body'] ??
                '')
            .toString();
    final sentAt = _parseDateTime(
      map['createdAt'] ?? map['created_at'] ?? map['sentAt'] ?? map['time'],
    );
    final fromUser = _resolveFromUser(map);
    return SupportMessage(
      id: id.isEmpty ? 'local_${sentAt.millisecondsSinceEpoch}' : id,
      message: content.isNotEmpty ? content : '[Attachment]',
      fromUser: fromUser,
      sentAt: sentAt,
      contentType: contentType,
    );
  }

  bool _resolveFromUser(Map<String, dynamic> map) {
    final fromUser = map['fromUser'];
    if (fromUser is bool) return fromUser;
    final sender = (map['sender'] ?? map['senderType'] ?? map['role'] ?? '')
        .toString()
        .toLowerCase();
    if (sender.contains('patient') || sender.contains('user')) return true;
    if (sender.contains('admin') || sender.contains('support')) return false;
    return false;
  }

  DateTime _parseDateTime(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }
    final parsed = DateTime.tryParse(raw.toString());
    return parsed ?? DateTime.now();
  }

  String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  void showToastMessage({required String message}) {
    final context = Get.context;
    if (context != null) {
      showToast(message: message, context: context);
    }
  }

  Future<void> fetchPrescriptions({bool remoteOnly = false}) async {
    try {
      isLoadingPrescriptions.value = true;
      final prefs = await SharedPreferences.getInstance();

      if (!remoteOnly) {
        final cached = prefs.getString(getAllPrescriptionListKey);
        if (cached != null && cached.isNotEmpty) {
          try {
            final decoded = jsonDecode(cached) as Map<String, dynamic>;
            final cachedResp = PrescriptionListResponseModel.fromJson(decoded);
            if (cachedResp.status == 'success' &&
                cachedResp.prescriptionListData?.prescriptionList != null) {
              final list = cachedResp.prescriptionListData!.prescriptionList!;
              apiPrescriptions.assignAll(list);
              prescriptions.assignAll(
                list
                    .map(
                      (p) => PrescriptionItem(
                        title: p.title ?? 'Prescription',
                        doctorName: p.patientDetails?.name ?? 'Doctor',
                        dateLabel: formatDate(p.createdAt),
                        status: 'Uploaded',
                      ),
                    )
                    .toList(),
              );
            }
          } catch (_) {
            // ignore cache parse errors
          }
        }
      }

      final selectedId = (selectedPatient.value?.id ?? '').trim();

      String profileId = '';
      try {
        final profileCtrl = Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController());

        profileId = (profileCtrl.profileData.value.profile?.sId ?? '').trim();
        if (profileId.isEmpty) {
          await profileCtrl.getProfileData();
          profileId = (profileCtrl.profileData.value.profile?.sId ?? '').trim();
        }
      } catch (_) {
        profileId = '';
      }

      final patientId = selectedId.isNotEmpty ? selectedId : profileId;
      if (patientId.isEmpty) {
        log('fetchPrescriptions: missing patient id');
        apiPrescriptions.clear();
        prescriptions.clear();
        return;
      }

      final params = {'patient': patientId};
      final resp = await _apiRepo.getPrescriptionList(params);
      log('fetchPrescriptions response status: ${resp.status}');

      await prefs.setString(
        getAllPrescriptionListKey,
        jsonEncode(resp.toJson()),
      );

      if (resp.status == 'success' &&
          resp.prescriptionListData?.prescriptionList != null) {
        final list = resp.prescriptionListData!.prescriptionList!;
        apiPrescriptions.assignAll(list);
        prescriptions.assignAll(
          list
              .map(
                (p) => PrescriptionItem(
                  title: p.title ?? 'Prescription',
                  doctorName: p.patientDetails?.name ?? 'Doctor',
                  dateLabel: formatDate(p.createdAt),
                  status: 'Uploaded',
                ),
              )
              .toList(),
        );
      }
    } catch (e, s) {
      log('fetchPrescriptions error: $e', stackTrace: s);
    } finally {
      isLoadingPrescriptions.value = false;
    }
  }

  String prescriptionDisplayTitle(Prescription prescription) {
    final raw = (prescription.title ?? '').trim();
    if (raw.isNotEmpty && raw.toLowerCase() != 'rx') return raw;
    final meds = (prescription.medicines ?? const [])
        .where((m) => (m.name ?? '').trim().isNotEmpty)
        .toList();
    if (meds.isNotEmpty) {
      final first = (meds.first.name ?? '').trim();
      if (meds.length > 1) return '$first (+${meds.length - 1})';
      return first;
    }
    return 'Medicine';
  }

  Future<void> deletePrescription(String id) async {
    try {
      final resp = await _apiRepo.deletePrescriptionFromList(id);
      if (resp['status'] == 'success') {
        showToastMessage(message: resp['message'] ?? 'Deleted');
        await fetchPrescriptions(remoteOnly: true);
      } else {
        showToastMessage(message: resp['message'] ?? 'Failed to delete');
      }
    } catch (e, s) {
      log('deletePrescription error: $e', stackTrace: s);
      showToastMessage(message: 'Failed to delete');
    }
  }

  Future<Options?> _buildDownloadOptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = (prefs.getString(userTokenKey) ?? '').trim();
      if (token.isEmpty) return null;
      return Options(headers: <String, String>{
        'Authorization': 'Bearer $token',
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> sharePrescription({
    required String? file,
    required String? title,
  }) async {
    try {
      if (file == null || file.isEmpty) {
        showToastMessage(message: 'Your prescription is invalid');
        return;
      }

      final resolvedUrl = file.startsWith('http')
          ? file
          : '${ApiConstants.imageBaseUrl}$file';

      final uri = Uri.tryParse(resolvedUrl);
      if (uri == null) {
        showToastMessage(message: 'Your prescription is invalid');
        return;
      }

      final directory = await getTemporaryDirectory();

      final ext = p.extension(uri.path);
      final safeExt = ext.isNotEmpty ? ext : '.jpg';
      final fileName =
          'prescription_${DateTime.now().millisecondsSinceEpoch}$safeExt';
      final path = p.join(directory.path, fileName);

      final options = await _buildDownloadOptions();
      await _dio.download(resolvedUrl, path, options: options);

      await Share.shareXFiles([XFile(path)], text: title ?? 'Prescription');
    } catch (e, s) {
      log('sharePrescription error: $e', stackTrace: s);
      showToastMessage(message: 'Failed to share prescription');
    }
  }

  Future<String?> _downloadToTempFile({
    required String url,
    required String prefix,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final directory = await getTemporaryDirectory();
    final ext = p.extension(uri.path);
    final safeExt = ext.isNotEmpty ? ext : '.pdf';
    final fileName =
        '${prefix}_${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final path = p.join(directory.path, fileName);

    final options = await _buildDownloadOptions();
    await _dio.download(url, path, options: options);
    return path;
  }

  Future<void> openPrescriptionPreview({
    required String fileUrl,
    String? title,
  }) async {
    try {
      final resolvedUrl = fileUrl.startsWith('http')
          ? fileUrl
          : '${ApiConstants.imageBaseUrl}$fileUrl';

      final localPath = await _downloadToTempFile(
        url: resolvedUrl,
        prefix: 'prescription',
      );

      if (localPath == null || localPath.isEmpty) {
        showToastMessage(message: 'Your prescription is invalid');
        return;
      }

      final result = await OpenFile.open(localPath);
      if ((result.type.name).toLowerCase() == 'error') {
        showToastMessage(message: 'Failed to open prescription');
      }
    } catch (e, s) {
      log('openPrescriptionPreview error: $e', stackTrace: s);
      showToastMessage(message: 'Failed to open prescription');
    }
  }
}
