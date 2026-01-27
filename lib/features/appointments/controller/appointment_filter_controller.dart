import 'package:get/get.dart';

enum AppointmentFilterType { past, upcoming, followup }

class AppointmentFilterController extends GetxController {
  Rx<AppointmentFilterType> appointmentType = AppointmentFilterType.past.obs;

  void changeAppointmentType(AppointmentFilterType type) {
    appointmentType.value = type;
  }
}
