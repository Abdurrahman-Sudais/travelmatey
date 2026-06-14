import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class TermsPoliciesPage extends StatelessWidget {
  const TermsPoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: Stack(
          children: [
            SafeArea(
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
                    const Text(
                      'Terms & Policies',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Header
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
                          Text(
                            'TRAVELMATE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Terms & Policies',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Operated by COTECH INVESTMENT LIMITED',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _highlightBox('TERMS & CONDITIONS (User Agreement)', [
                      'Effective Date: January 8, 2026',
                      'Last Updated: January 8, 2026',
                      'Governing Law: Nigeria',
                    ]),
                    const SizedBox(height: 16),
                    _infoBox(
                      'If you have a fare or money problem that this document cannot independently resolve, Travelmate does not provide independent financial services, data, or compensation for failed rides.',
                    ),
                    const SizedBox(height: 16),
                    _section('1. Nature of the Service', [
                      'Travelmate is a ride-sharing platform that:',
                      'Provides you with a regulated ride booking service',
                      'You must be registered and licensed, meet age 18+',
                      'You must keep your login* number consistent with legal register con and you should regularly check your profile con for completeness and accuracy.',
                    ]),
                    _section('1.2 Eligibility', [
                      'To use Travelmate you must:',
                      'Provide your real information',
                      'You must meet the standard and applicable legal risk requirements',
                      'Fees apply for each ride registration',
                    ]),
                    _section('1.3 Account Registration', [
                      'You agree to:',
                      'Provide accurate, current information',
                      'Keep your login details secure',
                      'Notify us of any unauthorized use',
                    ]),
                    _section('1.4 User Responsibilities', [
                      'We reserve the right to suspend or terminate accounts that:',
                      'Violate our policy or local and/or national laws',
                      'Make any false* claims and/or misuse any information',
                      'Receive consistently poor ratings',
                      'Abuse cancellations or any other policy violations',
                    ]),
                    _section('1.5 Driver Obligations', [
                      'Drivers must:',
                      'Maintain valid driver\'s license and insurance',
                      'Ensure vehicle is roadworthy and insured',
                      'Avoid harassment, discrimination, or illegal routes',
                      'Follow confirmed planned trips',
                    ]),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: const AppBottomNavBar(current: AppTab.profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightBox(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: kPrimaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: kPrimaryGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F0FE),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kPrimaryBlue.withOpacity(0.2)),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
    ),
  );

  Widget _section(String title, List<String> bullets) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.black38)),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                        height: 1.5,
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
}
