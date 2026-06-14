import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'kyc_page.dart';

/// Shows the "KYC Verification Required" modal that blocks an action
/// (e.g. searching for rides) until the user completes KYC.
///
/// Returns `true` if the user completed KYC via [KycPage] while this
/// dialog was open — the caller should retry the original action.
/// Returns `false`/`null` if dismissed ("Not Now" / X) without completing.
Future<bool?> showKycRequiredDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => const KycRequiredDialog(),
  );
}

class KycRequiredDialog extends StatelessWidget {
  const KycRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _actionBlockedBox(),
                  const SizedBox(height: 20),
                  const Text("Required Verification:",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _verificationRow(Icons.credit_card, "Banking Details"),
                  const SizedBox(height: 10),
                  _verificationRow(Icons.description_outlined, "Valid Identification"),
                  const SizedBox(height: 10),
                  _verificationRow(Icons.location_on_outlined, "Proof of Address"),
                  const SizedBox(height: 16),
                  _whyKycBox(),
                  const SizedBox(height: 20),
                  _startVerificationButton(context),
                  const SizedBox(height: 10),
                  _notNowButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A80), kErrorRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "KYC Verification Required",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text("Complete verification to continue",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, false),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBlockedBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAmber),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: kAmber, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Action Blocked",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kAmber.withOpacity(0.9))),
                const SizedBox(height: 4),
                const Text(
                  "You need to complete your KYC verification before you can search for rides.",
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationRow(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kErrorRed.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: kErrorRed, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _whyKycBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
      child: const Text(
        "Why KYC? We verify all users to ensure a safe and trusted community. Your information is encrypted and secure.",
        style: TextStyle(fontSize: 13, color: kPrimaryBlue, height: 1.4),
      ),
    );
  }

  Widget _startVerificationButton(BuildContext context) {
    return InkWell(
      onTap: () => _startVerification(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimaryBlue, Color(0xFF1E90FF)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text("Start Verification",
            style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _startVerification(BuildContext context) async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const KycPage()),
    );
    if (completed == true && context.mounted) {
      // KYC was completed inside KycPage — close this dialog and signal
      // success so the caller can retry the originally blocked action.
      Navigator.pop(context, true);
    }
  }

  Widget _notNowButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context, false),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: const Text("Not Now",
            style: TextStyle(color: Colors.black87, fontSize: 15.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}