import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelmateeee/core/services/auth_service.dart';

class PhoneAuthException implements Exception {
  final String message;
  PhoneAuthException(this.message);

  @override
  String toString() => message;
}

/// Sends SMS OTP via Firebase Phone Auth and returns an ID token for the API.
class PhoneAuthService {
  PhoneAuthService._();

  static final PhoneAuthService instance = PhoneAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  Future<void> sendOtp(String phone) async {
    final normalized = AuthService.normalizePhone(phone);
    final completer = Completer<void>();

    await _auth.verifyPhoneNumber(
      phoneNumber: normalized,
      forceResendingToken: _resendToken,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android auto-retrieval — store credential path via verificationId flow.
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            PhoneAuthException(_friendlyFirebaseError(e)),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  Future<String> confirmOtp(String smsCode) async {
    final verificationId = _verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      throw PhoneAuthException(
        'No verification in progress. Please request a new OTP.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final token = await userCredential.user?.getIdToken();
    if (token == null || token.isEmpty) {
      throw PhoneAuthException('Could not obtain verification token.');
    }
    return token;
  }

  Future<void> signOutFirebase() async {
    await _auth.signOut();
    _verificationId = null;
  }

  String _friendlyFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Enter a valid Nigerian phone number (e.g. 08012345678).';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Could not send OTP. Please try again.';
    }
  }
}
