import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/app/routes.dart';
import 'package:travelmateeee/core/base/active_role.dart';
import 'package:travelmateeee/core/auth/google_auth_flow.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/features/auth/view/forgot_password_page.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/services/google_sign_in_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/google_sign_in_button.dart';
import 'package:travelmateeee/features/home/view/home_page.dart' show activeRoleNotifier;

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

enum _SignInMethod { email, phone }

class _SignInPageState extends State<SignInPage> {
  _SignInMethod _method = _SignInMethod.email;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool get _googleAvailable =>
      GoogleSignInService.instance.isConfigured &&
      AppConfig.isGoogleSignInConfigured;

  bool get _canSubmit {
    final hasIdentifier = _method == _SignInMethod.email
        ? _emailCtrl.text.trim().isNotEmpty
        : _phoneCtrl.text.trim().isNotEmpty;
    return hasIdentifier && _passwordCtrl.text.isNotEmpty;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
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
                "Welcome Back!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Sign in to continue your journey",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              _methodToggle(),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _method == _SignInMethod.email
                    ? _emailField(key: const ValueKey("email_field"))
                    : _phoneField(key: const ValueKey("phone_field")),
              ),
              const SizedBox(height: 18),
              _passwordField(),
              const SizedBox(height: 14),
              _rememberMeRow(),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _signInButton(),
              if (_googleAvailable) ...[
                const SizedBox(height: 22),
                _orDivider(),
                const SizedBox(height: 22),
                _googleSignInButton(),
              ],
              const SizedBox(height: 22),
              _signUpRow(),
              const SizedBox(height: 40),
              _secureNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _methodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleButton("Email", _SignInMethod.email),
          _toggleButton("Phone Number", _SignInMethod.phone),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, _SignInMethod method) {
    final bool isActive = _method == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _method = method),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? kPrimaryBlue : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email Address",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

  Widget _phoneField({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Phone Number",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: "Enter your password",
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.black45,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFEDEDED),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _rememberMeRow() {
    final label = _method == _SignInMethod.email
        ? "Remember my email"
        : "Remember my phone number";
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _rememberMe,
            activeColor: kPrimaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Future<void> _submitSignIn() async {
    if (!_canSubmit || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final identifier = _method == _SignInMethod.email
          ? _emailCtrl.text.trim()
          : AuthService.normalizePhone(_phoneCtrl.text.trim());
      final user = await AuthService.instance.signIn(
        identifier,
        _passwordCtrl.text,
      );
      activeRoleNotifier.value =
          user.role == 'driver' ? ActiveRole.driver : ActiveRole.rider;
      if (!mounted) return;
      Get.offAllNamed(RouteConstants.HOME);
    } catch (e) {
      Get.snackbar(
        'Sign-in failed',
        e is ApiException ? e.message : e.toString(),
        backgroundColor: kErrorRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitGoogleSignIn() async {
    if (_isLoading || _isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);
    try {
      await GoogleAuthFlow.start(context, role: 'rider');
    } catch (e) {
      Get.snackbar(
        'Google sign-in failed',
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
            "OR",
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD9D9D9))),
      ],
    );
  }

  Widget _googleSignInButton() {
    final enabled = !_isLoading && !_isGoogleLoading;
    return GoogleSignInButton(
      enabled: enabled,
      isLoading: _isGoogleLoading,
      onTap: _submitGoogleSignIn,
    );
  }

  Widget _signInButton() {
    final bool enabled = _canSubmit && !_isLoading;
    return InkWell(
      onTap: enabled ? _submitSignIn : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryBlue : const Color(0xFFCFCFCF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                "Sign In",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: enabled ? Colors.white : Colors.white70,
                ),
              ),
      ),
    );
  }

  Widget _signUpRow() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            const TextSpan(text: "Don't have an account?  "),
            TextSpan(
              text: "Sign Up",
              style: const TextStyle(
                color: kPrimaryBlue,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.toNamed(RouteConstants.SIGNUP);
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _secureNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimaryBlue.withValues(alpha: 0.05),
        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.lock_outline, size: 18, color: kPrimaryBlue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Your connection is secure. We'll never share your "
              "credentials.",
              style: TextStyle(
                fontSize: 12.5,
                color: kPrimaryBlue,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
