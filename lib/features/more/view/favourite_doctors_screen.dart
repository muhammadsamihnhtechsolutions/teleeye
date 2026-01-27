import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/no_data_found_widget.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/doctor_list/view/doctor_profile_screen.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/view/card_skelton_screen.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteDoctorsScreen extends StatelessWidget {
  const FavouriteDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final MoreController controller = Get.find<MoreController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: l10n.favourite_doctors,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => controller.fetchFavoriteDoctors(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: controller.isLoadingFavoriteDoctors.value
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: const NewsCardSkelton(),
                  )
                : controller.favoriteDoctors.isNotEmpty
                ? ListView.builder(
                    itemCount: controller.favoriteDoctors.length,
                    padding: const EdgeInsets.only(bottom: 50, top: 10),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final doctor = controller.favoriteDoctors[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => DoctorProfileScreen(doctor: doctor));
                        },
                        child: _FavouriteDoctorListItem(
                          doctorName: doctor.name ?? '',
                          photo: doctor.photo ?? '',
                          specialties: doctor.specialty
                              .map((e) => e.title)
                              .toList()
                              .join(', '),
                          hospitals: doctor.hospital
                              .map((e) => e.name)
                              .toList()
                              .join(', '),
                          onRemove: () async {
                            final ok = await controller.removeFavoriteDoctor(
                              doctor,
                            );
                            if (ok) {
                              showToast(
                                message: l10n.remove_from_favourites,
                                context: context,
                              );
                            } else {
                              showToast(message: 'Failed', context: context);
                            }
                          },
                        ),
                      );
                    },
                  )
                : NoDataFoundWidget(
                    title: "You don't have any favourite doctor",
                  ),
          ),
        );
      }),
    );
  }
}

class _FavouriteDoctorListItem extends StatelessWidget {
  const _FavouriteDoctorListItem({
    required this.doctorName,
    required this.photo,
    required this.specialties,
    required this.hospitals,
    required this.onRemove,
  });

  final String doctorName;
  final String photo;
  final String specialties;
  final String hospitals;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      margin: EdgeInsets.only(bottom: getProportionateScreenWidth(10)),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: getProportionateScreenHeight(90),
            width: getProportionateScreenHeight(90),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: photo.isNotEmpty
                  ? CommonNetworkImageWidget(imageLink: photo)
                  : Container(color: AppColors.colorEDEDED),
            ),
          ),
          CommonSizeBox(width: getProportionateScreenWidth(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InterText(
                  title: doctorName,
                  textColor: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: getProportionateScreenHeight(6)),
                InterText(
                  title: specialties,
                  fontSize: 12,
                  textColor: AppColors.color888E9D,
                ),
                SizedBox(height: getProportionateScreenHeight(4)),
                InterText(
                  title: hospitals,
                  fontSize: 12,
                  textColor: Colors.black,
                ),
                SizedBox(height: getProportionateScreenHeight(14)),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              CommonSizeBox(
                                width: getProportionateScreenWidth(6),
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: InterText(
                                    title: l10n.remove_from_favourites,
                                    fontSize: 14,
                                    maxLines: 1,
                                    textColor: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    CommonSizeBox(width: getProportionateScreenWidth(8)),
                    Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.primaryColor,
                      ),
                      alignment: Alignment.center,
                      child: InterText(
                        title: l10n.book_now,
                        fontSize: 14,
                        maxLines: 1,
                        textColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
