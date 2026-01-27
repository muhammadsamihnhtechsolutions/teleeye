import 'package:eye_buddy/features/appointments/appointments_page.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/contollers/bottom_navbar_controller.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/widigets/bottom_navbar_widget.dart';
import 'package:eye_buddy/features/home/home_screen.dart';
import 'package:eye_buddy/features/more/more_screen.dart';
import 'package:eye_buddy/features/more/view/all_prescriptions_screen.dart';
import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen>
    with WidgetsBindingObserver {
  late final BottomNavBarController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BottomNavBarController());

    WidgetsBinding.instance.addObserver(this);

    // Check notification permissions when app opens
    _checkNotificationPermissions();

    _handlePendingNotificationNavigation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _handlePendingNotificationNavigation();
    }
  }

  Future<void> _handlePendingNotificationNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCriteria = prefs.getString(criteria) ?? '';
      if (savedCriteria != 'prescription') return;
      await prefs.setString(criteria, '');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Get.to(() => const AllPrescriptionsScreen());
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _checkNotificationPermissions() async {
    try {
      // Check Firebase permissions
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      print(
        "BottomNavBarScreen - Firebase permission status: ${settings.authorizationStatus}",
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        // Show user a dialog to enable notifications
        _showNotificationPermissionDialog();
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        // Request permission using Firebase
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      }
    } catch (e) {
      print("Error checking notification permissions: $e");
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications Required'),
          content: const Text(
            'Please enable notifications to receive incoming calls from doctors.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open app settings
                // You can use the 'app_settings' package for this
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomNavBarPages = [
      const HomeScreen(), // Home Page
      const AppointmentsPage(), // Appointments Page
      const MoreScreen(), // More Page
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bottomNavBarPages.length,
              itemBuilder: (context, index) {
                return bottomNavBarPages[index];
              },
              onPageChanged: (index) {
                controller.currentPageIndex.value = index;
              },
            ),
          ),
          BottomNavBarWidget(controller: controller),
        ],
      ),
    );
  }
}
