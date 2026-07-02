import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/auth/signup_draft.dart';
import 'package:travelmateeee/features/auth/view/phone_verification_page.dart';
import 'package:travelmateeee/features/profile/view/personal_information_page.dart';

class PasswordSetupPage extends StatefulWidget {
  const PasswordSetupPage({super.key});

  @override
  State<PasswordSetupPage> createState() => _PasswordSetupPageState();
}

class _PasswordSetupPageState extends State<PasswordSetupPage> {
  final _passwordCtrl = TextEditingController();
  final _repeatCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _repeatCtrl.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordCtrl.text.length >= 8;
  bool get _hasUpper => _passwordCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLower => _passwordCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _passwordsMatch =>
      _passwordCtrl.text.isNotEmpty && _passwordCtrl.text == _repeatCtrl.text;

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUpper) score++;
    if (_hasLower) score++;
    return score;
  }

  String get _strengthLabel {
    if (_passwordCtrl.text.isEmpty) return "Your password is weak";
    switch (_strengthScore) {
      case 0:
      case 1:
        return "Your password is weak";
      case 2:
        return "Your password is medium";
      default:
        return "Your password is strong";
    }
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 0:
      case 1:
        return kErrorRed;
      case 2:
        return kAmber;
      default:
        return kPrimaryGreen;
    }
  }

  bool get _canSave =>
      _hasMinLength && _hasUpper && _hasLower && _passwordsMatch;

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
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      "Password setup",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Choose password that you can remember but "
                      "hard for others to guess",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _passwordField(
                    controller: _passwordCtrl,
                    hint: "New password",
                    obscure: _obscure1,
                    onToggle: () => setState(() => _obscure1 = !_obscure1),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Strength",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  _strengthBar(_strengthScore),
                  const SizedBox(height: 6),
                  Text(
                    _strengthLabel,
                    style: TextStyle(fontSize: 12.5, color: _strengthColor),
                  ),
                  const SizedBox(height: 18),
                  _passwordField(
                    controller: _repeatCtrl,
                    hint: "Repeat new password",
                    obscure: _obscure2,
                    onToggle: () => setState(() => _obscure2 = !_obscure2),
                  ),
                  const SizedBox(height: 6),
                  _matchBar(),
                  const SizedBox(height: 18),
                  _requirementRow("8 characters minimum", _hasMinLength),
                  const SizedBox(height: 10),
                  _requirementRow("a upper case", _hasUpper),
                  const SizedBox(height: 10),
                  _requirementRow("a lower case", _hasLower),
                  const SizedBox(height: 50),
                  _saveButton(),
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
      child: const Icon(Icons.chevron_left, size: 24, color: Colors.black87),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.black45,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFEDEDED),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _strengthBar(int score) {
    final color = score == 0
        ? const Color(0xFFE8DADA)
        : score == 1
        ? kErrorRed
        : score == 2
        ? kAmber
        : kPrimaryGreen;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: score == 0 ? 0.05 : score / 3,
        minHeight: 6,
        backgroundColor: const Color(0xFFEDE3E3),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  Widget _matchBar() {
    final bool empty = _repeatCtrl.text.isEmpty;
    final color = empty
        ? const Color(0xFFEDE3E3)
        : _passwordsMatch
        ? kPrimaryGreen
        : kErrorRed;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: empty ? 0.05 : 1,
        minHeight: 6,
        backgroundColor: const Color(0xFFEDE3E3),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  Widget _requirementRow(String label, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: met ? kPrimaryGreen : Colors.black38,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: met ? Colors.black87 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Future<void> _savePassword() async {
    if (!_canSave || _isSaving) return;

    if (!SignUpDraft.phoneVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PhoneVerificationPage(
            phoneNumber: AuthService.normalizePhone(SignUpDraft.phone),
            email: SignUpDraft.email,
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final newPassword = _passwordCtrl.text;
      if (SignUpDraft.usedTempPassword && SignUpDraft.tempPassword.isNotEmpty) {
        await AuthService.instance.changePassword(
          oldPassword: SignUpDraft.tempPassword,
          newPassword: newPassword,
        );
        SignUpDraft.usedTempPassword = false;
      }
      SignUpDraft.password = newPassword;
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PersonalInformationPage()),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _saveButton() {
    final bool enabled = _canSave && !_isSaving;
    return InkWell(
      onTap: enabled ? _savePassword : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryBlue : const Color(0xFF9CA3AF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Save Password",
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
