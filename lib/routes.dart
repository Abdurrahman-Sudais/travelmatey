import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/screens/into/onboarding/onboarding.dart';
import 'package:travelmateeee/screens/into/onboarding/onboarding_view_model.dart';
// RoleAwareHome lives in main.dart; import it for the HOME route.
// ignore: implementation_imports
import 'package:travelmateeee/main.dart' show RoleAwareHome;

// ─── Route name constants ─────────────────────────────────────────────────────

class RouteConstants {
  RouteConstants._();

  static const String ONBOARDING = '/onboarding';
  static const String SIGNIN = '/signin';
  static const String SIGNUP = '/signup';
  static const String HOME = '/home';
}

// ─── Bindings ─────────────────────────────────────────────────────────────────

/// Registers dependencies needed by the [Onboarding] screen.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnBoardingViewModel>(() => OnBoardingViewModel());
  }
}

// ─── App Pages ────────────────────────────────────────────────────────────────

class AppPages {
  AppPages._();

  static const String initial = RouteConstants.ONBOARDING;

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: RouteConstants.ONBOARDING,
      page: () => const Onboarding(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: RouteConstants.SIGNIN,
      page: () => const _SignInPlaceholder(),
    ),
    GetPage(
      name: RouteConstants.SIGNUP,
      page: () => const _SignUpPlaceholder(),
    ),
    GetPage(
      name: RouteConstants.HOME,
      page: () => const RoleAwareHome(),
    ),
  ];
}

// ─── Placeholder screens (replace with real implementations) ─────────────────

class _SignInPlaceholder extends StatelessWidget {
  const _SignInPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: const Center(
        child: Text(
          'Sign In Screen\n(Replace with real implementation)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _SignUpPlaceholder extends StatelessWidget {
  const _SignUpPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: const Center(
        child: Text(
          'Sign Up Screen\n(Replace with real implementation)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
