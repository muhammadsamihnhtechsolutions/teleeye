import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/get_doctor_rating_model.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum DoctorProfileFilterType { info, experience, feedback }

class DoctorProfileController extends GetxController {
  final Doctor? doctor;
  final bool isFromFavoriteList;

  DoctorProfileController({this.doctor, this.isFromFavoriteList = false});

  late final PageController pageController;
  final currentFilterType = DoctorProfileFilterType.info.obs;
  final selectedDoctor = Rxn<Doctor>();

  final isFeedbackLoading = false.obs;
  final feedbackErrorMessage = ''.obs;
  final feedbackModel = Rxn<GetDoctorRatingModel>();

  final isFavoriteLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    if (doctor != null) {
      selectedDoctor.value = doctor;
    }

    // Preload feedback so the tab is ready when user switches.
    loadDoctorFeedback();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void updateFilterType(DoctorProfileFilterType type) {
    currentFilterType.value = type;
    final pageIndex = type == DoctorProfileFilterType.info
        ? 0
        : type == DoctorProfileFilterType.experience
        ? 1
        : 2;
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    final type = index == 0
        ? DoctorProfileFilterType.info
        : index == 1
        ? DoctorProfileFilterType.experience
        : DoctorProfileFilterType.feedback;
    currentFilterType.value = type;

    if (type == DoctorProfileFilterType.feedback &&
        feedbackModel.value == null) {
      loadDoctorFeedback();
    }
  }

  void updateSelectedDoctor(Doctor doctor) {
    selectedDoctor.value = doctor;
    loadDoctorFeedback();
  }

  Future<void> loadDoctorFeedback() async {
    final doctorId = selectedDoctor.value?.id ?? doctor?.id ?? '';
    if (doctorId.isEmpty) {
      feedbackErrorMessage.value = 'Doctor ID is missing';
      return;
    }

    isFeedbackLoading.value = true;
    feedbackErrorMessage.value = '';
    try {
      final res = await ApiRepo().getDoctorRating(doctorId);
      feedbackModel.value = res;
      if ((res.status ?? '').toLowerCase() != 'success' &&
          (res.message ?? '').isNotEmpty) {
        feedbackErrorMessage.value = res.message ?? '';
      }
    } catch (e) {
      feedbackErrorMessage.value = e.toString();
    } finally {
      isFeedbackLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (isFavoriteLoading.value) return;
    final current = selectedDoctor.value ?? doctor;
    final doctorId = (current?.id ?? '').trim();
    if (current == null || doctorId.isEmpty) return;

    final wasFavorite = current.isFavorite ?? false;

    // Optimistic UI update (matches BLoC's setState toggle)
    current.isFavorite = !wasFavorite;
    selectedDoctor.refresh();

    isFavoriteLoading.value = true;
    try {
      final resp = wasFavorite
          ? await ApiRepo().removeDoctorFromFavoritesDoctorList(doctorId)
          : await ApiRepo().addDoctorToFavoritesDoctorList(doctorId);

      final ok = (resp.status ?? '').toLowerCase() == 'success';
      if (!ok) {
        current.isFavorite = wasFavorite;
        selectedDoctor.refresh();
      } else {
        if (Get.isRegistered<MoreController>()) {
          await Get.find<MoreController>().fetchFavoriteDoctors();
        }
      }

      final context = Get.context;
      if (context != null) {
        showToast(
          message: resp.message ?? (ok ? 'Success' : 'Failed'),
          context: context,
        );
      }
    } catch (e) {
      current.isFavorite = wasFavorite;
      selectedDoctor.refresh();
    } finally {
      isFavoriteLoading.value = false;
    }
  }
}
