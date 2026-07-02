import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/features/auth/view/sign_in_page.dart';
import 'package:travelmateeee/features/auth/view/sign_up_page.dart';
import 'package:travelmateeee/features/auth/view/splash_page.dart';
import 'package:travelmateeee/shared/widgets/main_shell.dart';
import 'package:travelmateeee/features/onboarding/view/onboarding_page.dart';
import 'package:travelmateeee/features/onboarding/view_model/onboarding_view_model.dart';

// ─── Route name constants ─────────────────────────────────────────────────────

class RouteConstants {
  RouteConstants._();

  // ignore: constant_identifier_names
  static const String ONBOARDING = '/onboarding';
  // ignore: constant_identifier_names
  static const String SIGNIN = '/signin';
  // ignore: constant_identifier_names
  static const String SIGNUP = '/signup';
  // ignore: constant_identifier_names
  static const String HOME = '/home';
}

// ─── Bindings ─────────────────────────────────────────────────────────────────

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<OnBoardingViewModel>(OnBoardingViewModel());
  }
}

// ─── App Pages ────────────────────────────────────────────────────────────────

class AppPages {
  AppPages._();

  static const String initial = '/';

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: '/',
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteConstants.ONBOARDING,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    ),
    GetPage(
      name: RouteConstants.SIGNIN,
      page: () => const SignInPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: RouteConstants.SIGNUP,
      page: () => const SignUpPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: RouteConstants.HOME,
      page: () => const MainShell(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    ),
  ];
}
