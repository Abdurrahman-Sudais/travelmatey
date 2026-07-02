import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/app/routes.dart';
import 'package:travelmateeee/core/auth/google_auth_flow.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/auth/signup_draft.dart';
import 'package:travelmateeee/shared/widgets/google_sign_in_button.dart';
import 'phone_verification_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _role = 'rider';
  bool _isGoogleLoading = false;

  bool get _canContinue =>
      _emailCtrl.text.trim().isNotEmpty && _phoneCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(),
              const SizedBox(height: 16),
              const Text(
                "Create Your Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Enter your details to get started on your journey",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 28),
              _emailField(),
              const SizedBox(height: 6),
              const Text(
                "We'll send a verification link to this email",
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
              const SizedBox(height: 20),
              _phoneField(),
              const SizedBox(height: 6),
              const Text(
                "We'll send an OTP to verify your phone number",
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
              const SizedBox(height: 20),
              _roleSelector(),
              const SizedBox(height: 40),
              _continueButton(),
              const SizedBox(height: 20),
              _orDivider(),
              const SizedBox(height: 20),
              _googleSignInButton(),
              const SizedBox(height: 20),
              _signInRow(),
              const SizedBox(height: 60),
              _termsNotice(),
            ],
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

  Widget _emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(text: "Email Address "),
              TextSpan(text: "*", style: TextStyle(color: kErrorRed)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: "example@email.com",
            icon: Icons.mail_outline,
          ),
        ),
      ],
    );
  }

  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(text: "Phone Number "),
              TextSpan(text: "*", style: TextStyle(color: kErrorRed)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: "08012345678",
            icon: Icons.call_outlined,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      filled: true,
      fillColor: const Color(0xFFEDEDED),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _roleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "I want to join as",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _roleChip('Rider', 'rider'),
            const SizedBox(width: 10),
            _roleChip('Driver', 'driver'),
          ],
        ),
      ],
    );
  }

  Widget _roleChip(String label, String value) {
    final selected = _role == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _role = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? kPrimaryBlue.withValues(alpha: 0.1)
                : const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? kPrimaryBlue : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? kPrimaryBlue : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  void _continueSignUp() {
    if (!_canContinue) return;

    SignUpDraft.reset();
    SignUpDraft.email = _emailCtrl.text.trim();
    SignUpDraft.phone = _phoneCtrl.text.trim();
    SignUpDraft.role = _role;
    SignUpDraft.usedTempPassword = true;
    SignUpDraft.tempPassword = SignUpDraft.generateTempPassword();
    SignUpDraft.password = SignUpDraft.tempPassword;
    SignUpDraft.firstName = SignUpDraft.placeholderFirstName;
    SignUpDraft.lastName = SignUpDraft.placeholderLastName;

    final phone = AuthService.normalizePhone(SignUpDraft.phone);

    // Phone must be verified via Firebase OTP BEFORE signup API accepts the number.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhoneVerificationPage(
          phoneNumber: phone,
          email: SignUpDraft.email,
        ),
      ),
    );
  }

  Future<void> _submitGoogleSignUp() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);
    try {
      await GoogleAuthFlow.start(context, role: _role);
    } catch (e) {
      Get.snackbar(
        'Google sign-up failed',
        e is ApiException ? e.message : e.toString(),
        backgroundColor: kErrorRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Widget _orDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD9D9D9))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD9D9D9))),
      ],
    );
  }

  Widget _googleSignInButton() {
    return GoogleSignInButton(
      enabled: !_isGoogleLoading,
      isLoading: _isGoogleLoading,
      onTap: _submitGoogleSignUp,
    );
  }

  Widget _continueButton() {
    final bool enabled = _canContinue;
    return InkWell(
      onTap: enabled ? _continueSignUp : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryBlue : const Color(0xFFCFCFCF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Continue",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _signInRow() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            const TextSpan(text: "Already have an account?  "),
            TextSpan(
              text: "Sign In",
              style: const TextStyle(
                color: kPrimaryBlue,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.offNamed(RouteConstants.SIGNIN);
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _termsNotice() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(fontSize: 12, color: Colors.black45),
          children: [
            TextSpan(text: "By continuing, you agree to our "),
            TextSpan(
              text: "Terms of Service",
              style: TextStyle(
                color: kPrimaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(
                color: kPrimaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
