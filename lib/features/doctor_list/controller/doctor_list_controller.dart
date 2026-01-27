import 'dart:async';
import 'dart:developer';

import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class DoctorListController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();

  final isLoading = false.obs;
  final doctors = <Doctor>[].obs;
  final scrollController = ScrollController();

  final isLoadingSpecialties = false.obs;
  final specialties = <Specialty>[].obs;
  final Rx<Specialty?> selectedSpecialty = Rx<Specialty?>(null);
  final currentRating = ''.obs;

  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchSpecialties();
    fetchDoctors();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchSpecialties() async {
    try {
      isLoadingSpecialties.value = true;
      final res = await _apiRepo.getSpecialtiesList();
      if (res.status == 'success' && res.specialtyList != null) {
        specialties.assignAll(res.specialtyList!);
      } else {
        specialties.clear();
      }
    } catch (_) {
      specialties.clear();
    } finally {
      isLoadingSpecialties.value = false;
    }
  }

  Future<void> fetchDoctors({String? search}) async {
    _searchQuery = search ?? _searchQuery;
    isLoading.value = true;
    try {
      final params = <String, String>{};
      if (_searchQuery.isNotEmpty) {
        params['search'] = _searchQuery;
      }

      if (selectedSpecialty.value?.id != null &&
          (selectedSpecialty.value!.id ?? '').isNotEmpty) {
        params['specialty'] = selectedSpecialty.value!.id!;
      }
      if (currentRating.value.isNotEmpty) {
        params['minRating'] = currentRating.value;
      }

      final resp = await _apiRepo.getDoctorList(params);
      if (resp.status == 'success' &&
          resp.doctorListResponseData?.doctorList != null) {
        doctors.assignAll(resp.doctorListResponseData!.doctorList!);
      } else {
        doctors.clear();
      }
    } catch (e, s) {
      log('fetchDoctors error: $e', stackTrace: s);
      doctors.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchDoctors(search: '');
  }

  void onSearchChanged(String value) {
    final trimmed = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = trimmed;
      fetchDoctors(search: trimmed);
    });
  }

  void updateSelectedSpecialty(Specialty? specialty) {
    selectedSpecialty.value = specialty;
  }

  void updateCurrentRating(String rating) {
    currentRating.value = (currentRating.value == rating) ? '' : rating;
  }

  void clearFilters() {
    selectedSpecialty.value = null;
    currentRating.value = '';
    fetchDoctors();
  }

  void applyFilters() {
    fetchDoctors();
  }
}
