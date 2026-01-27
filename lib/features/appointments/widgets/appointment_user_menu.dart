import 'package:eye_buddy/core/services/api/model/patient_list_model.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/appointments/controller/appointment_controller.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/appointments/widgets/appointment_user_popup.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentUserMenu extends StatelessWidget {
  const AppointmentUserMenu({super.key});

  String _patientImageLink(MyPatient p) {
    final photo = (p.photo ?? '').trim();
    if (photo.isEmpty || photo.toLowerCase() == 'null') return '';
    return '${ApiConstants.imageBaseUrl}$photo';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<AppointmentController>();

    return Obx(() {
      final MyPatient? current = controller.selectedPatient.value;
      final items = controller.patients.toList();
      return PopupMenuButton<String>(
        offset: const Offset(1, 0),
        position: PopupMenuPosition.under,
        itemBuilder: (context) {
          return items.map((p) {
            return PopupMenuItem<String>(
              value: p.id ?? '',
              onTap: () {
                controller.selectPatient(p);
              },
              child: SizedBox(
                width: getProportionateScreenWidth(200),
                child: AppointmentUserPopUpWidget(
                  userName: (p.relation?.isNotEmpty == true
                      ? p.relation!
                      : (p.name ?? '')),
                  image: _patientImageLink(p),
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          height: getProportionateScreenHeight(45),
          width: getProportionateScreenWidth(150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.colorBBBBBB),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: getProportionateScreenHeight(30),
                    width: getProportionateScreenHeight(30),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CommonNetworkImageWidget(
                        imageLink: current == null
                            ? ''
                            : _patientImageLink(current),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InterText(
                    title: _capitalizeFirstWord(
                      (current?.relation?.isNotEmpty == true
                              ? current!.relation
                              : current?.name) ??
                          l10n.myself,
                    ),
                    fontSize: 14,
                  ),
                ],
              ),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
      );
    });
  }
}

String _capitalizeFirstWord(String input) {
  if (input.isEmpty) return input;
  final parts = input.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return input;
  final first = parts.first;
  final capitalized = first.isEmpty
      ? first
      : '${first[0].toUpperCase()}${first.substring(1)}';
  return [capitalized, ...parts.skip(1)].join(' ');
}
