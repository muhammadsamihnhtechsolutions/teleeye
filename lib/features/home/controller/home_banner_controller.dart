// import 'dart:developer';
// import 'package:eye_buddy/core/services/api/model/banner_response_model.dart';
// import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
// import 'package:get/get.dart';

// class HomeBannerController extends GetxController {
//   final ApiRepo _apiRepo = ApiRepo();

//   RxBool isLoading = false.obs;
//   RxList<Banner> bannerList = <Banner>[].obs;
//   String? errorMessage;

//   @override
//   void onInit() {
//     super.onInit();
//     getHomeBannersList();
//   }

//   Future<void> getHomeBannersList() async {
//     try {
//       isLoading.value = true;
//       errorMessage = null;

//       final response = await _apiRepo.getHomeBanners();

//       if (response.status == 'success' && response.bannerList != null) {
//         bannerList.value = response.bannerList!;
//       } else {
//         errorMessage = response.message ?? 'Failed to load banners';
//         bannerList.clear();
//       }
//     } catch (e) {
//       log("Get home banners error: $e");
//       errorMessage = 'An error occurred while fetching banners';
//       bannerList.clear();
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void resetState() {
//     isLoading.value = false;
//     errorMessage = null;
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

class HomeBannerAdController extends GetxController {
  BannerAd? bannerAd;
  final RxBool isLoaded = false.obs;

  bool _isLoading = false;

  bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get adUnitId {
    if (!isSupportedPlatform) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/6300978111';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/2934735716';
      default:
        return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAd();
  }

  /// ✅ SINGLE & SAFE LOAD
  void loadAd() {
    if (!isSupportedPlatform) return;
    if (adUnitId.isEmpty) return;
    if (_isLoading || bannerAd != null) return;

    _isLoading = true;
    isLoaded.value = false;

    bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isLoaded.value = true;
          _isLoading = false;
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          bannerAd = null;
          isLoaded.value = false;
          _isLoading = false;
        },
      ),
    )..load();
  }

  /// 🔁 Screen re-open fix
  void reloadIfNeeded() {
    if (bannerAd == null && !_isLoading) {
      loadAd();
    }
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    bannerAd = null;
    super.onClose();
  }
}
