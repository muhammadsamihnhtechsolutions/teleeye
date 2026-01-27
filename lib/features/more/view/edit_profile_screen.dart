import 'dart:io';
import 'package:eye_buddy/core/services/api/model/profile_reponse_model.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/input_formatters/max_int_text_input_formatter.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/controller/edit_profile_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileController controller;

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
                    await controller.pickImage(
                      source: ImageSource.camera,
                      context: context,
                    );
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
                    await controller.pickImage(
                      source: ImageSource.gallery,
                      context: context,
                    );
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
  void initState() {
    super.initState();
    controller = Get.put(EditProfileController());
    controller.setProfile(widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: "Edit Profile",
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),

      // ===== Bottom Save Button =====
      bottomNavigationBar: Obx(
        () => Padding(
          padding: EdgeInsets.only(
            left: getProportionateScreenWidth(20),
            right: getProportionateScreenWidth(20),
            bottom: getProportionateScreenWidth(12),
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  height: kToolbarHeight * 1.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 1.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Loading...",
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                )
              : CustomButton(
                  title: "Save",
                  callBackFunction: () {
                    controller.saveProfile();
                  },
                ),
        ),
      ),

      // ===== Main Body =====
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSizeBox(height: getProportionateScreenHeight(12)),

              // ===== Profile Image =====
              Obx(
                () => Center(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: getProportionateScreenHeight(100),
                        width: getProportionateScreenHeight(100),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: controller.selectedImage.value != null
                              ? Image.file(
                                  controller.selectedImage.value!,
                                  fit: BoxFit.cover,
                                )
                              : CommonNetworkImageWidget(
                                  imageLink: () {
                                    final photo =
                                        (controller.profile.photo ?? '').trim();
                                    if (photo.isEmpty) return '';
                                    final isAbsolute =
                                        Uri.tryParse(photo)?.isAbsolute ??
                                        false;
                                    if (isAbsolute) return photo;
                                    return '${ApiConstants.imageBaseUrl}$photo';
                                  }(),
                                  boxFit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => _pickProfileImage(context),
                          child: Container(
                            height: getProportionateScreenHeight(30),
                            width: getProportionateScreenWidth(30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.colorCCE7D9,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              // child: Image.asset(AppAssets.upload),
                              child: SvgPicture.asset(AppAssets.upload),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              CommonSizeBox(height: getProportionateScreenHeight(16)),

              // ===== NAME =====
              InterText(
                title: "Full Name",
                fontSize: 14,
                textColor: AppColors.color888E9D,
              ),
              CommonSizeBox(height: 8),
              CustomTextFormField(
                textEditingController: controller.nameController,
              ),

              CommonSizeBox(height: 16),

              // ===== DOB =====
              InterText(
                title: "Date of Birth",
                fontSize: 14,
                textColor: AppColors.color888E9D,
              ),
              CommonSizeBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    controller.dobController.text = "${pickedDate.toLocal()}"
                        .split(' ')[0];
                  }
                },
                child: CustomTextFormField(
                  textEditingController: controller.dobController,
                  suffixSvgPath: AppAssets.calender,
                  isEnabled: false,
                ),
              ),

              CommonSizeBox(height: 16),

              // ===== WEIGHT =====
              InterText(
                title: "Weight",
                fontSize: 14,
                textColor: AppColors.color888E9D,
              ),
              CommonSizeBox(height: 8),
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

              CommonSizeBox(height: 16),

              // ===== GENDER =====
              InterText(
                title: "Gender",
                fontSize: 14,
                textColor: AppColors.color888E9D,
              ),
              CommonSizeBox(height: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  controller.genderController.text = value;
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "Male", child: Text("Male")),
                  PopupMenuItem(value: "Female", child: Text("Female")),
                ],
                child: CustomTextFormField(
                  textEditingController: controller.genderController,
                  suffixSvgPath: AppAssets.arrowDown,
                  isEnabled: false,
                ),
              ),

              CommonSizeBox(height: 16),

              // ===== EMAIL =====
              InterText(
                title: "Email (Optional)",
                fontSize: 14,
                textColor: AppColors.color888E9D,
              ),
              CommonSizeBox(height: 8),
              CustomTextFormField(
                textEditingController: controller.emailController,
                hint: "Enter your email address",
              ),

              CommonSizeBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
