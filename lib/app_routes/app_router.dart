// app_routes.dart
import 'package:eye_buddy/features/login/view/login_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  // Named routes
  static const root = '/';
  static const LoginScreen = '/loginScreen';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LoginScreen,
      page: () => LoginScreen(showBackButton: false),
      transition: Transition.fade,
    ),
  ];
}
