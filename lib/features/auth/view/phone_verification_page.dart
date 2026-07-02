

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/services/firebase_bootstrap.dart';
import 'package:travelmateeee/core/services/phone_auth_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/auth/signup_draft.dart';
import 'package:travelmateeee/features/profile/view/personal_information_page.dart';
import 'email_verification_page.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final bool isGoogleOnboarding;

  const PhoneVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.email,
    this.isGoogleOnboarding = false,
  });

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  int _secondsRemaining = 60;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _isSendingOtp = false;
  bool _otpSent = false;
  String? _sendError;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _sendOtp();
  }

  Future<void> _sendOtp() async {
    if (_isSendingOtp) return;

    if (!FirebaseBootstrap.isReady) {
      setState(() {
        _sendError =
            'SMS verification is not configured yet. Ask your backend team for '
            'Firebase credentials, then run the app with --dart-define=FIREBASE_API_KEY=... '
            '(or use flutterfire configure).';
      });
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _sendError = null;
    });

    try {
      await PhoneAuthService.instance.sendOtp(widget.phoneNumber);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _secondsRemaining = 60;
      });
      _timer?.cancel();
      _startTimer();
    } on PhoneAuthException catch (e) {
      setState(() => _sendError = e.message);
    } catch (e) {
      setState(() => _sendError = 'Could not send OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _isComplete => _controllers.every((c) => c.text.trim().length == 1);

  String get _enteredOtp => _controllers.map((c) => c.text.trim()).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index].text.length),
      );
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (!_isComplete || _isVerifying || !_otpSent) return;

    final enteredOtp = _enteredOtp;

    setState(() => _isVerifying = true);
    try {
      final firebaseToken =
          await PhoneAuthService.instance.confirmOtp(enteredOtp);

      await AuthService.instance.verifyOtp(
        phone: widget.phoneNumber,
        firebaseIdToken: firebaseToken,
      );

      await PhoneAuthService.instance.signOutFirebase();

      if (widget.isGoogleOnboarding) {
        SignUpDraft.phone = widget.phoneNumber;
        SignUpDraft.phoneVerified = true;

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PersonalInformationPage(),
          ),
        );
        return;
      }

      final pendingSession = await AuthService.instance.signUpForVerification(
        firstName: SignUpDraft.firstName,
        lastName: SignUpDraft.lastName,
        email: widget.email,
        phone: widget.phoneNumber,
        password: SignUpDraft.password,
        role: SignUpDraft.role,
      );

      SignUpDraft.userId = pendingSession.user.id;
      SignUpDraft.token = pendingSession.token;
      SignUpDraft.refreshToken = pendingSession.refreshToken;
      SignUpDraft.phoneVerified = true;

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(email: widget.email),
        ),
      );
    } on PhoneAuthException catch (e) {
      _showError(e.message);
      _clearOtp();
    } on ApiException catch (e) {
      _showError(_friendlyOtpError(e.message));
      _clearOtp();
    } catch (e) {
      _showError('Could not verify OTP. Please try again.');
      _clearOtp();
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0 || _isResending || _isSendingOtp) return;

    setState(() => _isResending = true);
    try {
      await _sendOtp();
      _clearOtp();
      Get.snackbar(
        'OTP resent',
        'Check your messages.',
        backgroundColor: kPrimaryGreen,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes.first.requestFocus();
    }
    if (mounted) setState(() {});
  }

  String _friendlyOtpError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('phone') && lower.contains('not verified')) {
      return 'Phone verification failed. Please check the code and try again.';
    }
    if (lower.contains('already') && lower.contains('verified')) {
      return 'This phone number is already verified. Please sign in.';
    }
    if (lower.contains('expired')) {
      return 'Your OTP has expired. Please request a new code.';
    }
    if (lower.contains('invalid')) {
      return 'Invalid OTP. Please check the code and try again.';
    }
    return message;
  }

  void _showError(String message) {
    Get.snackbar(
      message,
      '',
      backgroundColor: kErrorRed,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          _backgroundRipples(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(),
                  const SizedBox(height: 60),
                  const Center(
                    child: Text(
                      "Phone verification",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        children: [
                          TextSpan(
                            text: _isSendingOtp
                                ? "Sending OTP to\n"
                                : _otpSent
                                    ? "We've sent an SMS with an OTP code to\n"
                                    : "We'll send an OTP to\n",
                          ),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isSendingOtp) ...[
                    const SizedBox(height: 24),
                    const Center(
                      child: CircularProgressIndicator(color: kPrimaryBlue),
                    ),
                  ],
                  if (_sendError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kErrorRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: kErrorRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _sendError!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _sendOtp,
                        child: const Text('Retry sending OTP'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Enter your OTP Code",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        "${_secondsRemaining}s",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kErrorRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _otpRow(),
                  const SizedBox(height: 24),
                  _verifyButton(),
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        children: [
                          const TextSpan(text: "Didn't receive code? "),
                          TextSpan(
                            text: _isResending ? "Resending..." : "Resend OTP",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _secondsRemaining == 0 && !_isSendingOtp
                                  ? kPrimaryBlue
                                  : Colors.black38,
                            ),
                            recognizer:
                                _secondsRemaining == 0 && !_isSendingOtp
                                    ? (TapGestureRecognizer()..onTap = _resend)
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundRipples() {
    return Positioned(
      top: -100,
      right: -100,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.4,
          child: SizedBox(
            width: 360,
            height: 360,
            child: CustomPaint(painter: _RipplePainter()),
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _otpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (i) {
        return SizedBox(
          width: 48,
          height: 64,
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            enabled: !_isVerifying && _otpSent,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: const Color(0xFFEDEDED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryBlue, width: 1.5),
              ),
            ),
            onChanged: (v) => _onChanged(i, v),
          ),
        );
      }),
    );
  }

  Widget _verifyButton() {
    final bool enabled = _isComplete && !_isVerifying && _otpSent;
    return InkWell(
      onTap: enabled ? _verifyOtp : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryBlue : const Color(0xFF9CA3AF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Verify",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width, 0);
    for (int i = 1; i <= 6; i++) {
      canvas.drawCircle(center, i * 30.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
