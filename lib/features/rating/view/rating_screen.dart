import 'dart:developer';

import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/custom_loader.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final ApiRepo _apiRepo = ApiRepo();

  final RxBool _isLoading = false.obs;
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (_isLoading.value) return;

    if (_reviewController.text.trim().isEmpty) {
      showToast(
        message: AppLocalizations.of(context)!.review_cannot_be_empty,
        context: context,
      );
      return;
    }

    _isLoading.value = true;
    try {
      final resp = await _apiRepo.submitRating({
        'appointment': widget.appointmentId,
        'rating': _rating,
        'review': _reviewController.text.trim(),
      });

      if (resp.status == 'success') {
        Get.back(result: true);
        return;
      }

      showToast(
        message:
            resp.message ?? AppLocalizations.of(context)!.an_error_occurred,
        context: context,
      );
    } catch (e) {
      log('RatingScreen submit error: $e');
      showToast(
        message: AppLocalizations.of(context)!.an_error_occurred,
        context: context,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonAppBar(
        title: l10n.rating,
        elevation: 0,
        icon: Icons.close,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Container(
            height: getHeight(context: context),
            width: getWidth(context: context),
            color: Colors.white,
            child: const CustomLoadingScreen(),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: getWidth(context: context),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.colorEFEFEF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      InterText(
                        title: l10n.how_was_the_doctor,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 10),
                      RatingBar.builder(
                        initialRating: 0,
                        itemSize: 45,
                        maxRating: 5,
                        ignoreGestures: false,
                        allowHalfRating: true,
                        itemPadding: const EdgeInsets.symmetric(
                          horizontal: 0.5,
                        ),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rate_rounded,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (val) {
                          _rating = val;
                          log('Rating: $val');
                        },
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                InterText(title: l10n.leave_a_comment),
                const SizedBox(height: 6),
                CustomTextFormField(
                  textEditingController: _reviewController,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  title: l10n.submit,
                  callBackFunction: () => _submit(context),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
