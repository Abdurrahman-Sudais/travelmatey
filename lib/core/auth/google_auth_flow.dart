import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/app/routes.dart';
import 'package:travelmateeee/core/auth/google_auth_result.dart';
import 'package:travelmateeee/core/base/active_role.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/services/google_sign_in_service.dart';
import 'package:travelmateeee/features/auth/signup_draft.dart';
import 'package:travelmateeee/features/auth/view/google_phone_page.dart';
import 'package:travelmateeee/features/auth/view/phone_verification_page.dart';
import 'package:travelmateeee/features/home/view/home_page.dart' show activeRoleNotifier;
import 'package:travelmateeee/features/profile/view/personal_information_page.dart';

/// Routes users after Google Sign-In — existing users go home, new users complete
/// the same registration steps as email sign-up (phone → profile).
class GoogleAuthFlow {
  GoogleAuthFlow._();

  /// Picks a Google account, calls the API, then navigates appropriately.
  static Future<void> start(
    BuildContext context, {
    required String role,
  }) async {
    final pickerResult = await GoogleSignInService.instance.signIn();
    if (pickerResult == null || !context.mounted) return;

    final authResult = await AuthService.instance.authenticateWithGoogle(
      credential: pickerResult.credential,
      googleUserInfo: pickerResult.userInfo,
      role: role,
    );

    if (!context.mounted) return;
    await _routeAfterAuth(context, authResult, pickerResult.userInfo, role);
  }

  static Future<void> _routeAfterAuth(
    BuildContext context,
    GoogleAuthResult authResult,
    Map<String, dynamic> googleUserInfo,
    String role,
  ) async {
    _seedDraft(authResult, googleUserInfo, role);

    if (!authResult.needsOnboarding) {
      activeRoleNotifier.value =
          authResult.user.role == 'driver' ? ActiveRole.driver : ActiveRole.rider;
      Get.offAllNamed(RouteConstants.HOME);
      return;
    }

    if (authResult.user.phone.trim().isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GooglePhonePage()),
      );
      return;
    }

    if (!SignUpDraft.phoneVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PhoneVerificationPage(
            phoneNumber: AuthService.normalizePhone(SignUpDraft.phone),
            email: SignUpDraft.email,
            isGoogleOnboarding: true,
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PersonalInformationPage(),
      ),
    );
  }

  static void _seedDraft(
    GoogleAuthResult authResult,
    Map<String, dynamic> googleUserInfo,
    String role,
  ) {
    SignUpDraft.reset();
    SignUpDraft.isGoogleAuth = true;
    SignUpDraft.skipPasswordSetup = true;
    SignUpDraft.emailVerified = true;
    SignUpDraft.role = role.isNotEmpty ? role : authResult.user.role;
    SignUpDraft.email = authResult.user.email.isNotEmpty
        ? authResult.user.email
        : googleUserInfo['email']?.toString() ?? '';
    SignUpDraft.phone = authResult.user.phone;
    SignUpDraft.firstName = authResult.user.firstName.isNotEmpty
        ? authResult.user.firstName
        : googleUserInfo['given_name']?.toString() ?? '';
    SignUpDraft.lastName = authResult.user.lastName.isNotEmpty
        ? authResult.user.lastName
        : googleUserInfo['family_name']?.toString() ?? '';
    SignUpDraft.userId = authResult.user.id;
    SignUpDraft.token = authResult.token;
    SignUpDraft.refreshToken = authResult.refreshToken;
    SignUpDraft.phoneVerified = authResult.user.phone.isNotEmpty &&
        authResult.user.isVerified &&
        !authResult.isNewUser;
  }
}
