import 'dart:async';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/home/widgets/home_app_bar.dart';
import 'package:eye_buddy/features/home/widgets/home_feature_section.dart';
import 'package:eye_buddy/features/home/widgets/home_slider_section.dart';
import 'package:eye_buddy/features/home/controller/home_banner_controller.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize controllers
    // Get.put(HomeBannerController());
    // ProfileController should already be initialized, but ensure it's available
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<ProfileController>().getProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeAppBar(),
            SizedBox(
              width: SizeConfig.screenWidth,
              child: const HomeFeatureSection(),
            ),
            CommonSizeBox(height: 10),
            // const HomeSliderSection(),
            SizedBox(height: 10),
            SizedBox(height: kToolbarHeight),
          ],
        ),
      ),
    );
  }
}
