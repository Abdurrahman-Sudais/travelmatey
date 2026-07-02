import 'package:flutter/material.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/auth/signup_draft.dart';
import 'package:travelmateeee/features/auth/view/phone_verification_page.dart';

/// Collects a phone number for new Google sign-ups before OTP verification.
class GooglePhonePage extends StatefulWidget {
  const GooglePhonePage({super.key});

  @override
  State<GooglePhonePage> createState() => _GooglePhonePageState();
}

class _GooglePhonePageState extends State<GooglePhonePage> {
  final _phoneCtrl = TextEditingController();

  bool get _canContinue => _phoneCtrl.text.trim().length >= 10;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_canContinue) return;
    final phone = AuthService.normalizePhone(_phoneCtrl.text.trim());
    SignUpDraft.phone = phone;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PhoneVerificationPage(
          phoneNumber: phone,
          email: SignUpDraft.email,
          isGoogleOnboarding: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Add your phone number',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'We need to verify your number to keep your ${SignUpDraft.role == 'driver' ? 'driver' : 'rider'} account secure.',
                style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
              ),
              if (SignUpDraft.email.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle_outlined,
                          color: kPrimaryBlue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          SignUpDraft.email,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const Text(
                'Phone Number',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '08012345678',
                  prefixIcon: const Icon(Icons.call_outlined, color: Colors.black45),
                  filled: true,
                  fillColor: const Color(0xFFEDEDED),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _canContinue ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    disabledBackgroundColor: const Color(0xFFCFCFCF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Send verification code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
