import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.chevron_left, size: 22),
                          Text('Back', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Privacy & Security',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    // Header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('PRIVACY & SECURITY POLICY',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1)),
                          SizedBox(height: 4),
                          Text('TRAVELMATE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          Text('Operated by: COTECH INVESTMENT LIMITED',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text('RC No. 101039',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text(
                              'Registered Address: No 31, BU of Bofey State, Nigeria.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoBox(
                      'Effective Date: January 8, 2026\nLast Updated: January 8, 2026',
                    ),
                    const SizedBox(height: 16),
                    _bodyText(
                        'Travelmate ("we," "us," or "it") is a digital carpooling platform created and operated by COTECH Investment Limited (RC No. 101039). We are committed to protecting your privacy and ensuring the security of your personal data.'),
                    const SizedBox(height: 12),
                    _bodyText(
                        'This Privacy & Security Policy explains how we collect, use, store, disclose, and protect your personal information when you use the Travelmate mobile application, website, and related services ("Platform").'),
                    const SizedBox(height: 6),
                    _link('This policy is issued in accordance with the Nigerian Data Protection Act (NDPA) 2023 and applicable regulations.'),
                    const SizedBox(height: 20),
                    _sectionTitle('1. Information We Collect'),
                    const SizedBox(height: 12),
                    _subSection('1.1 Personal & KYC Data', [
                      'Full name, phone number, email address',
                      'Profile photo, date of birth, residential or business address',
                      'Government-issued identification (for KYC verification)',
                      'Vehicle details (drivers)',
                      'Emergency contact (optional)',
                    ]),
                    const SizedBox(height: 12),
                    _subSection('1.2 Financial & Wallet Data', [
                      'Wallet balances and transaction history',
                      'Ride payments, advances and driver payouts',
                      'Bank account details',
                      'Tokenized payment information from licensed payment processors (we do not store card or bank details)',
                    ]),
                    const SizedBox(height: 12),
                    _subSection('1.3 Trip, Communication & Location Data', [
                      'Pickup and drop-off locations, routes, dates, times',
                      'Ride requests, acceptances, cancellations',
                      'In-app messages',
                      'Ratings and reviews',
                      'Real-time GPS tracking during active trips (with permission)',
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle('2. How We Use Your Data'),
                    const SizedBox(height: 12),
                    _greenBox([
                      'Provide ride matching, booking, and matching services',
                      'Conduct KYC verification and fraud prevention',
                      'Operate the Travelmate Wallet and escrow system',
                      'Enable GPS navigation, trip tracking, safety, and dispute resolution',
                      'Send confirmations, notifications, and customer support messages',
                    ]),
                  ],
                ),
              )),
      ),
    );
  }

  Widget _bodyText(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
      );

  Widget _link(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.3)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, color: kPrimaryBlue, height: 1.5)),
      );

  Widget _infoBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, color: Colors.black45, height: 1.6)),
      );

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87));

  Widget _subSection(String title, List<String> bullets) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue)),
            const SizedBox(height: 10),
            ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(color: Colors.black54)),
                      Expanded(
                          child: Text(b,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.black54,
                                  height: 1.4))),
                    ],
                  ),
                )),
          ],
        ),
      );

  Widget _greenBox(List<String> bullets) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryGreen.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.check_circle_outline,
                    color: kPrimaryGreen, size: 18),
                SizedBox(width: 8),
                Text('We Use Your Information To:',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryGreen)),
              ],
            ),
            const SizedBox(height: 10),
            ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(color: Colors.black54)),
                      Expanded(
                          child: Text(b,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.black54,
                                  height: 1.4))),
                    ],
                  ),
                )),
          ],
        ),
      );
}