// import 'dart:convert';
// import 'dart:io';
// import 'package:eye_buddy/core/services/api/model/profile_reponse_model.dart';
// import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileController extends GetxController {
//   final ApiRepo _apiRepo = ApiRepo();

//   // Form Controllers
//   final nameController = TextEditingController();
//   final dobController = TextEditingController();
//   final weightController = TextEditingController();
//   final genderController = TextEditingController(text: "Male");

//   // Profile image
//   Rx<File?> selectedProfileImage = Rx<File?>(null);

//   // Loading state
//   var isLoading = false.obs;

//   // Pick image from gallery or camera
//   Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(source: source);
//     if (pickedFile != null) {
//       selectedProfileImage.value = File(pickedFile.path);
//     }
//   }

//   // Upload profile image in Base64
//   Future<ProfileResponseModel?> uploadProfileImage() async {
//     if (selectedProfileImage.value == null) return null;

//     try {
//       isLoading.value = true;
//       final bytes = await selectedProfileImage.value!.readAsBytes();
//       final base64Image = base64Encode(bytes);

//       final response = await _apiRepo.uploadProfileImageInBase64(base64Image);

//       isLoading.value = false;
//       return response;
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('Error', 'Failed to upload profile image');
//       return null;
//     }
//   }

//   // Update profile data
//   Future<ProfileResponseModel?> updateProfileData() async {
//     try {
//       isLoading.value = true;

//       Map<String, dynamic> parameters = {
//         "name": nameController.text,
//         "dateOfBirth": dobController.text,
//         "weight": weightController.text,
//         "gender": genderController.text,
//       };

//       final response = await _apiRepo.updateProfileData(parameters);

//       isLoading.value = false;

//       if (response.status == "success") {
//         Get.snackbar('Success', 'Profile updated successfully');
//       } else {
//         Get.snackbar('Error', response.message ?? 'Failed to update profile');
//       }

//       return response;
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('Error', 'Failed to update profile');
//       return null;
//     }
//   }

//   // Clear selected image
//   void clearSelectedImage() {
//     selectedProfileImage.value = null;
//   }
// }
import 'dart:io';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/input_formatters/max_int_text_input_formatter.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/login/controller/Save_User_Data_Controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../global_widgets/custom_text_field.dart';
import '../../global_widgets/filled_button.dart';
import '../../global_widgets/inter_text.dart';

import '../../../l10n/app_localizations.dart';

class SaveUserDataScreen extends StatelessWidget {
  SaveUserDataScreen({Key? key}) : super(key: key);

  final SaveUserDataController controller = Get.put(SaveUserDataController());

  Future<void> _pickProfileImage(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            width: MediaQuery.of(ctx).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.pickImage(source: ImageSource.camera);
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, size: 40),
                      SizedBox(height: 12),
                      Text('Capture\nImage', textAlign: TextAlign.center),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.pickImage(source: ImageSource.gallery);
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image, size: 40),
                      SizedBox(height: 12),
                      Text('Select\nImage', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: kToolbarHeight),
                  InterText(
                    title: l10n.please_enter_your_information,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 20),
                  // Profile Image
                  SizedBox(
                    height: 110,
                    width: 110,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(110),
                          child: controller.selectedProfileImage.value == null
                              ? Container(
                                  height: 110,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(110),
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: AppColors.primaryColor,
                                  ),
                                )
                              : Image.file(
                                  File(
                                    controller.selectedProfileImage.value!.path,
                                  ),
                                  fit: BoxFit.fill,
                                  width: 110,
                                  height: 110,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _pickProfileImage(context),
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: AppColors.colorCCE7D9,
                                borderRadius: BorderRadius.circular(35),
                              ),
                              child: SvgPicture.asset(AppAssets.upload),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  InterText(title: l10n.full_name, fontSize: 11),
                  SizedBox(height: 8),
                  CustomTextFormField(
                    textEditingController: controller.nameController,
                  ),
                  SizedBox(height: 16),
                  InterText(title: l10n.date_of_birth, fontSize: 11),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => controller.pickDate(context),
                    child: CustomTextFormField(
                      textEditingController: controller.dobController,
                      suffixSvgPath: AppAssets.calender,
                      isEnabled: false,
                    ),
                  ),
                  SizedBox(height: 16),
                  InterText(title: l10n.weight, fontSize: 11),
                  SizedBox(height: 8),
                  CustomTextFormField(
                    textEditingController: controller.weightController,
                    suffixSvgPath: AppAssets.kg,
                    textInputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                      const MaxIntTextInputFormatter(max: 999),
                    ],
                  ),
                  SizedBox(height: 25),
                  InterText(title: l10n.gender, fontSize: 11),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: controller.genderController.text.isEmpty
                        ? null
                        : controller.genderController.text,
                    hint: Text(l10n.gender),
                    items: ['Male', 'Female']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == 'Male' ? l10n.male : l10n.female),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.genderController.text = value!;
                    },
                    decoration: InputDecoration(
                      suffixIcon: SvgPicture.asset(AppAssets.arrowDown),
                    ),
                  ),
                  SizedBox(height: 40),
                  GetFilledButton(
                    title: l10n.save_continue.toUpperCase(),
                    callBackFunction: controller.saveUserData,
                  ),
                ],
              ),
            ),
            if (controller.isLoading.value)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
