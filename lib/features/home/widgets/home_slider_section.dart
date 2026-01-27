// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:eye_buddy/core/services/api/model/banner_response_model.dart';
// import 'package:eye_buddy/core/services/api/service/api_constants.dart';
// import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
// import 'package:eye_buddy/core/services/utils/size_config.dart';
// import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
// import 'package:eye_buddy/features/home/controller/home_banner_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class HomeSliderSection extends StatefulWidget {
//   const HomeSliderSection({super.key});

//   @override
//   State<HomeSliderSection> createState() => _HomeSliderSectionState();
// }

// class _HomeSliderSectionState extends State<HomeSliderSection> {
//   int currentIndex = 0;
//   final CarouselSliderController _controller = CarouselSliderController();

//   @override
//   Widget build(BuildContext context) {
//     final bannerController = Get.find<HomeBannerController>();

//     return Obx(() {
//       if (bannerController.isLoading.value) {
//         return const SizedBox(
//           height: 184,
//           child: Center(child: CircularProgressIndicator()),
//         );
//       }

//       if (bannerController.bannerList.isEmpty) {
//         return const SizedBox.shrink();
//       }

//       return Column(
//         children: [
//           SizedBox(
//             child: CarouselSlider(
//               carouselController: _controller,
//               options: CarouselOptions(
//                 aspectRatio: 2,
//                 viewportFraction: 1,
//                 onPageChanged: (index, reason) {
//                   setState(() {
//                     currentIndex = index;
//                   });
//                 },
//               ),
//               items: bannerController.bannerList
//                   .map(
//                     (item) => Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: getProportionateScreenWidth(20),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(6),
//                         child: SizedBox(
//                           height: 184,
//                           child: CommonNetworkImageWidget(
//                             imageLink:
//                                 '${ApiConstants.imageBaseUrl}${item.file}',
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: bannerController.bannerList.asMap().entries.map((entry) {
//               return GestureDetector(
//                 onTap: () => _controller.animateToPage(entry.key),
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   margin: const EdgeInsets.symmetric(
//                     vertical: 8,
//                     horizontal: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: currentIndex == entry.key
//                         ? AppColors.primaryColor
//                         : AppColors.colorCCE7D9,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       );
//     });
//   }
// }
