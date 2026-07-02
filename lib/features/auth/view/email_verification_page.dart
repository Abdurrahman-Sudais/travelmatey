import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/auth/signup_draft.dart';
import 'password_setup_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerified() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final verified = await AuthService.instance.isEmailVerified();
      if (!mounted) return;
      if (verified) {
        SignUpDraft.emailVerified = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PasswordSetupPage()),
        );
      } else {
        Get.snackbar(
          'Email not verified yet',
          'Open the link in your inbox, then tap the button again.',
          backgroundColor: kAmber,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        e.message,
        '',
        backgroundColor: kErrorRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendEmail() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    try {
      await AuthService.instance.resendSignupOtp(
        firstName: SignUpDraft.firstName,
        lastName: SignUpDraft.lastName,
        email: SignUpDraft.email,
        phone: SignUpDraft.phone,
        password: SignUpDraft.password,
        role: SignUpDraft.role,
      );
      Get.snackbar(
        'Verification email resent',
        'Check your inbox and spam folder.',
        backgroundColor: kPrimaryGreen,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        e.message,
        '',
        backgroundColor: kErrorRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _skipForNow() {
    Get.snackbar(
      'Email verification required',
      'Open the link in your inbox, then tap the verification button.',
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
                  _backButton(context),
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: kPrimaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Check Your Mail",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "We've sent a verification link to",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Click the link in the email to verify your "
                      "account and complete your registration.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _nextStepsCard(),
                  const SizedBox(height: 36),
                  _verifiedButton(),
                  const SizedBox(height: 16),
                  _bottomLinks(),
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

  Widget _backButton(BuildContext context) {
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

  Widget _nextStepsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Next Steps:",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 14),
          _stepRow("1", "Open your email inbox"),
          const SizedBox(height: 12),
          _stepRow("2", "Find the email from TravelMate"),
          const SizedBox(height: 12),
          _stepRow("3", "Click the verification link"),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: kAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Check your spam folder if you don't see the email "
              "in your inbox.",
              style: TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(String number, String text) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kPrimaryBlue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _verifiedButton() {
    final enabled = !_isChecking;
    return InkWell(
      onTap: enabled ? _checkVerified : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryGreen : const Color(0xFF9CA3AF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isChecking
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                "I've Verified My Email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _bottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: _isResending ? null : _resendEmail,
          child: Text(
            _isResending ? "Resending..." : "Resend Email",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: _isResending ? Colors.black38 : kPrimaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 24),
        InkWell(
          onTap: _skipForNow,
          child: const Text(
            "Skip for Now",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black38,
            ),
          ),
        ),
      ],
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
