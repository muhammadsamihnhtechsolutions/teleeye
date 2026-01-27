import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/appointments/controller/appointment_controller.dart';
import 'package:eye_buddy/features/appointments/controller/appointment_filter_controller.dart';
import 'package:eye_buddy/features/appointments/widgets/appointment_filter.dart';
import 'package:eye_buddy/features/appointments/widgets/appointment_tile_widget.dart';
import 'package:eye_buddy/features/appointments/widgets/appointment_user_menu.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/no_data_found_widget.dart';
import 'package:eye_buddy/features/more/view/card_skelton_screen.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize controllers
    if (!Get.isRegistered<AppointmentFilterController>()) {
      Get.put(AppointmentFilterController());
    }
    if (!Get.isRegistered<AppointmentController>()) {
      Get.put(AppointmentController());
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final localLanguage = AppLocalizations.of(context)!;
    final appointmentController = Get.find<AppointmentController>();
    final filterController = Get.find<AppointmentFilterController>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(),
      ),
      backgroundColor: AppColors.appBackground,
      body: RefreshIndicator(
        onRefresh: appointmentController.refreshScreen,
        child: SizedBox(
          child: Stack(
            children: [
              SizedBox(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
                            height: kToolbarHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InterText(
                                  fontSize: 20,
                                  title: localLanguage.appointments,
                                  fontWeight: FontWeight.bold,
                                ),
                                const AppointmentUserMenu(),
                              ],
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(10)),
                          const AppointmentsFilter(),
                          SizedBox(height: getProportionateScreenHeight(12)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        final filterType =
                            filterController.appointmentType.value;
                        final appointmentResponse =
                            filterType == AppointmentFilterType.past
                            ? appointmentController.pastAppointments.value
                            : filterType == AppointmentFilterType.upcoming
                            ? appointmentController.upcomingAppointments.value
                            : appointmentController.followupAppointments.value;

                        if (appointmentResponse == null ||
                            appointmentResponse.appointmentList == null ||
                            appointmentResponse
                                    .appointmentList!
                                    .appointmentData ==
                                null ||
                            appointmentResponse
                                .appointmentList!
                                .appointmentData!
                                .isEmpty) {
                          String noDataMessage =
                              localLanguage.you_dont_have_any_past_appointments;
                          if (filterType == AppointmentFilterType.upcoming) {
                            noDataMessage = localLanguage
                                .you_dont_have_any_upcoming_appointments;
                          } else if (filterType ==
                              AppointmentFilterType.followup) {
                            noDataMessage = localLanguage
                                .you_dont_have_any_follow_up_appointments;
                          }
                          return NoDataFoundWidget(title: noDataMessage);
                        }

                        return ListView.builder(
                          itemCount: appointmentResponse
                              .appointmentList!
                              .appointmentData!
                              .length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final appointment = appointmentResponse
                                .appointmentList!
                                .appointmentData![index];

                            return AppointmentTileWidget(
                              appointmentType: filterType,
                              appointmentData: appointment,
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Obx(() {
                return appointmentController.isLoading.value
                    ? const NewsCardSkelton()
                    : const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
// import 'package:eye_buddy/core/services/utils/size_config.dart';
// import 'package:eye_buddy/features/appointments/controller/appointment_controller.dart';
// import 'package:eye_buddy/features/appointments/controller/appointment_filter_controller.dart';
// import 'package:eye_buddy/features/appointments/widgets/appointment_filter.dart';
// import 'package:eye_buddy/features/appointments/widgets/appointment_tile_widget.dart';
// import 'package:eye_buddy/features/appointments/widgets/appointment_user_menu.dart';
// import 'package:eye_buddy/features/global_widgets/inter_text.dart';
// import 'package:eye_buddy/features/global_widgets/no_data_found_widget.dart';
// import 'package:eye_buddy/features/more/view/card_skelton_screen.dart';
// import 'package:eye_buddy/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AppointmentsPage extends StatefulWidget {
//   const AppointmentsPage({super.key});

//   @override
//   State<AppointmentsPage> createState() => _AppointmentsPageState();
// }

// class _AppointmentsPageState extends State<AppointmentsPage> {
//   late final AppointmentController appointmentController;
//   late final AppointmentFilterController filterController;

//   @override
//   void initState() {
//     super.initState();

//     appointmentController = Get.isRegistered<AppointmentController>()
//         ? Get.find<AppointmentController>()
//         : Get.put(AppointmentController());

//     filterController = Get.isRegistered<AppointmentFilterController>()
//         ? Get.find<AppointmentFilterController>()
//         : Get.put(AppointmentFilterController());
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     final localLanguage = AppLocalizations.of(context)!;

//     return Scaffold(
//       backgroundColor: AppColors.appBackground,
//       body: RefreshIndicator(
//         onRefresh: appointmentController.refreshScreen,
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 /// ---------------- HEADER ----------------
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 12),
//                       SizedBox(
//                         height: kToolbarHeight,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             InterText(
//                               title: localLanguage.appointments,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             const AppointmentUserMenu(),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: getProportionateScreenHeight(10)),
//                       const AppointmentsFilter(),
//                       SizedBox(height: getProportionateScreenHeight(12)),
//                     ],
//                   ),
//                 ),

//                 /// ---------------- LIST ----------------
//                 Expanded(
//                   child: Obx(() {
//                     final filterType =
//                         filterController.appointmentType.value;

//                     final appointmentResponse =
//                         _getAppointmentsByType(filterType);

//                     final appointmentList = appointmentResponse
//                         ?.appointmentList
//                         ?.appointmentData;

//                     if (appointmentList == null ||
//                         appointmentList.isEmpty) {
//                       return NoDataFoundWidget(
//                         title: _getNoDataMessage(
//                           filterType,
//                           localLanguage,
//                         ),
//                       );
//                     }

//                     return ListView.builder(
//                       padding: const EdgeInsets.only(bottom: 20),
//                       itemCount: appointmentList.length,
//                       itemBuilder: (_, index) {
//                         return AppointmentTileWidget(
//                           appointmentType: filterType,
//                           appointmentData: appointmentList[index],
//                         );
//                       },
//                     );
//                   }),
//                 ),
//               ],
//             ),

//             /// ---------------- LOADER ----------------
//             Obx(() {
//               return appointmentController.isLoading.value
//                   ? const NewsCardSkelton()
//                   : const SizedBox.shrink();
//             }),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ------------------------------------------------
//   /// HELPERS
//   /// ------------------------------------------------

//   dynamic _getAppointmentsByType(AppointmentFilterType type) {
//     switch (type) {
//       case AppointmentFilterType.upcoming:
//         return appointmentController.upcomingAppointments.value;
//       case AppointmentFilterType.followup:
//         return appointmentController.followupAppointments.value;
//       case AppointmentFilterType.past:
//       default:
//         return appointmentController.pastAppointments.value;
//     }
//   }

//   String _getNoDataMessage(
//     AppointmentFilterType type,
//     AppLocalizations localLanguage,
//   ) {
//     switch (type) {
//       case AppointmentFilterType.upcoming:
//         return localLanguage.you_dont_have_any_upcoming_appointments;
//       case AppointmentFilterType.followup:
//         return localLanguage.you_dont_have_any_follow_up_appointments;
//       case AppointmentFilterType.past:
//       default:
//         return localLanguage.you_dont_have_any_past_appointments;
//     }
//   }
// }
