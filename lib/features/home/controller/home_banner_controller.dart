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

