import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/functions.dart';
import 'package:eye_buddy/core/services/utils/global_variables.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/doctor_list/controller/doctor_list_controller.dart';
import 'package:eye_buddy/features/doctor_list/view/doctor_profile_screen.dart';
import 'package:eye_buddy/features/doctor_list/widgets/doctor_filter_bottom_sheet.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late final DoctorListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DoctorListController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.doctors.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_off_outlined,
                      color: AppColors.primaryColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const InterText(
                    title: "You don't have any doctor",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const InterText(
                    title:
                        'Please try again later or go back to home to explore other options.',
                    fontSize: 12,
                    textColor: AppColors.color888E9D,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    title: 'Go to Home',
                    callBackFunction: () {
                      Get.offAll(() => const BottomNavBarScreen());
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: Column(
            children: [
              _DoctorSearchBar(onChanged: controller.onSearchChanged),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CommonSizeBox(height: getProportionateScreenHeight(12)),
                      ListView.builder(
                        itemCount: controller.doctors.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final doctor = controller.doctors[index];
                          return GestureDetector(
                            onTap: () => Get.to(
                              () => DoctorProfileScreen(doctor: doctor),
                            ),
                            child: _DoctorListItem(doctor: doctor),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

String _capitalizeFirstWord(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

class _DoctorSearchBar extends StatelessWidget {
  const _DoctorSearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: AppColors.white,
      height: kToolbarHeight + 20,
      child: Row(
        children: [
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.appBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              height: 45,
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(15),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 15,
                    width: 15,
                    child: SvgPicture.asset(AppAssets.search),
                  ),
                  Expanded(
                    child: TextFormField(
                      onChanged: (searchText) {
                        onChanged(searchText);
                      },
                      keyboardType: TextInputType.text,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      cursorColor: AppColors.primaryColor,
                      decoration: InputDecoration(
                        hintText: l10n.search_doctor,
                        hintStyle: const TextStyle(
                          color: AppColors.colorBBBBBB,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 30, width: 1, color: AppColors.colorEDEDED),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const DoctorFilterBottomSheet(),
                      );
                    },
                    child: SvgPicture.asset(
                      AppAssets.filter,
                      height: getProportionateScreenWidth(20),
                      width: getProportionateScreenWidth(20),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _DoctorListItem extends StatelessWidget {
  const _DoctorListItem({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          width: SizeConfig.screenWidth,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(20),
                  vertical: 15,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: getProportionateScreenWidth(75),
                          width: getProportionateScreenWidth(75),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              getProportionateScreenWidth(75),
                            ),
                            child: CommonNetworkImageWidget(
                              imageLink: (doctor.photo ?? ''),
                            ),
                          ),
                        ),
                        CommonSizeBox(height: getProportionateScreenWidth(5)),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            InterText(
                              title:
                                  '${doctor.averageRating ?? 0} (${doctor.ratingCount ?? 0})',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ],
                    ),
                    CommonSizeBox(width: getProportionateScreenWidth(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: InterText(
                                  title: doctor.name ?? 'Doctor',
                                  textColor: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CommonSizeBox(
                                width: getProportionateScreenWidth(8),
                              ),
                              Container(
                                height: 25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: AppColors.primaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                alignment: Alignment.center,
                                child: InterText(
                                  title: _capitalizeFirstWord(
                                    doctor.availabilityStatus ?? '',
                                  ),
                                  fontSize: 12,
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: getProportionateScreenHeight(5)),
                          InterText(
                            title: doctor.about ?? '',
                            fontSize: 12,
                            maxLines: 2,
                            textColor: AppColors.color888E9D,
                          ),
                          SizedBox(height: getProportionateScreenHeight(5)),
                          if (doctor.hospital != null &&
                              doctor.hospital.isNotEmpty)
                            SizedBox(
                              width: SizeConfig.screenWidth / 2,
                              child: InterText(
                                title:
                                    '${doctor.hospital.map((e) => e.name).toList().join(", ")}',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                textColor: Colors.black,
                              ),
                            ),
                          SizedBox(height: getProportionateScreenHeight(16)),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: InterText(
                                      title: l10n.experience_in,
                                      fontSize: 12,
                                      textColor: AppColors.color888E9D,
                                    ),
                                  ),
                                  Gap(2),
                                  SizedBox(
                                    child: InterText(
                                      title:
                                          '${doctor.experienceInYear ?? 0} ${l10n.years}',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      textColor: AppColors.color030330,
                                    ),
                                  ),
                                ],
                              ),
                              CommonSizeBox(
                                width: getProportionateScreenWidth(50),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  // await Clipboard.setData(ClipboardData(text: "${doctor.bmdcCode!.trim().toString()}"));
                                  // showToast(message: "Copied to Clipboard ${doctor.bmdcCode!.trim().toString()}", context: context);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      child: InterText(
                                        title: 'BMDC No',
                                        fontSize: 12,
                                        textColor: AppColors.color888E9D,
                                      ),
                                    ),
                                    Gap(2),
                                    SizedBox(
                                      child: InterText(
                                        title:
                                            getShortAppointmentId(
                                              appointmentId: doctor.bmdcCode,
                                              wantedLength: 5,
                                            ) ??
                                            "NO_ID",
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        textColor: AppColors.color030330,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: AppColors.colorEDEDED,
                height: getProportionateScreenHeight(1),
                width: double.maxFinite,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(20),
                  top: getProportionateScreenWidth(10),
                  bottom: getProportionateScreenWidth(10),
                ),
                child: Row(
                  children: [
                    FutureBuilder(
                      builder: (ctx, snapshot) {
                        // Displaying LoadingSpinner to indicate waiting state
                        return InterText(
                          title: '$getCurrencySymbol ${snapshot.data ?? ''}',
                        );
                      },
                      initialData: "",
                      future: getDoctorConsultationFee(doctor: doctor),
                    ),
                    InterText(
                      title: '  (incl vat) per consultation',
                      fontSize: 12,
                      textColor: AppColors.color888E9D,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.color888E9D,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1.5,
          width: double.maxFinite,
          color: AppColors.color008541,
        ),
        Gap(12),
      ],
    );
  }
}
