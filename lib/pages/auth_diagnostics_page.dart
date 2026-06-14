import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/emergency_sos.dart';

class _DiagStep {
  final int number;
  final String title;
  final bool? passed; // null = pending/running
  final String? details;

  const _DiagStep({
    required this.number,
    required this.title,
    this.passed,
    this.details,
  });
}

class AuthDiagnosticsPage extends StatefulWidget {
  const AuthDiagnosticsPage({super.key});

  @override
  State<AuthDiagnosticsPage> createState() => _AuthDiagnosticsPageState();
}

class _AuthDiagnosticsPageState extends State<AuthDiagnosticsPage> {
  bool _hasApiError = true;
  bool _isRunning = false;
  List<_DiagStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  void _loadSteps() {
    _steps = [
      const _DiagStep(
        number: 1,
        title: 'Checking localStorage for auth token...',
      ),
      const _DiagStep(
        number: 1,
        title: 'Token exists in localStorage',
        passed: true,
        details: 'Token length: 206 characters',
      ),
      const _DiagStep(
        number: 2,
        title: 'Validating token structure...',
        passed: false,
        details: 'header.payload.signature)',
      ),
      const _DiagStep(
        number: 3,
        title: 'Decoding token payload...',
      ),
      const _DiagStep(
        number: 3,
        title: 'Token payload decoded successfully',
        passed: true,
        details:
            '{\n  "userId": "user_mock_123",\n  "email": "demo@travelmate.ng",\n  "role": "authenticated",\n  "issuedAt": "5/31/2026, 11:12:21 AM",\n  "expireAt": "6/7/2026, 11:12:21 AM"\n}',
      ),
      const _DiagStep(
        number: 4,
        title: 'Checking token expiration...',
      ),
      const _DiagStep(
        number: 4,
        title: 'Token valid for 9897 more minutes',
        passed: true,
        details: 'Expires at: 6/7/2026, 11:32:21 AM',
      ),
      const _DiagStep(
        number: 5,
        title: 'Checking required JWT claims...',
      ),
      const _DiagStep(
        number: 5,
        title: 'All required claims present (sub, exp, iat)',
        passed: true,
      ),
      const _DiagStep(
        number: 6,
        title: 'Checking stored user data...',
      ),
      const _DiagStep(
        number: 6,
        title: 'User data found and valid',
        passed: true,
        details:
            '{\n  "id": "user_mock_123",\n  "email": "demo@travelmate.ng",\n  "phone": "+2348812345678",\n  "kycStatus": "verified"\n}',
      ),
      const _DiagStep(
        number: 7,
        title: 'Testing API connectivity to /auth/me...',
      ),
      const _DiagStep(
        number: 7,
        title: 'NETWORK ERROR',
        passed: false,
        details: 'Failed to fetch',
      ),
    ];
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _hasApiError = false;
      _steps = [];
    });
    // Simulate running
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isRunning = false;
      _hasApiError = true;
      _loadSteps();
    });
  }

  void _clearStorage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage cleared. Please sign in again.')),
    );
  }

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
                          Icon(Icons.arrow_back, size: 20),
                          SizedBox(width: 4),
                          Text('Back', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Authentication Diagnostics',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Troubleshoot login and data loading issues',
                        style:
                            TextStyle(fontSize: 12, color: Colors.black45)),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        _actionBtn(
                          label: 'Run Diagnostics',
                          icon: Icons.play_arrow,
                          color: kPrimaryBlue,
                          onTap: _runDiagnostics,
                        ),
                        const SizedBox(width: 10),
                        _actionBtn(
                          label: 'Clear Storage',
                          icon: Icons.delete_outline,
                          color: kErrorRed,
                          onTap: _clearStorage,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _actionBtn(
                      label: 'Sign Out',
                      icon: Icons.logout,
                      color: Colors.black54,
                      outlined: true,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 16),
                    if (_isRunning)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (!_isRunning && _hasApiError) ...[
                      _errorBanner(),
                      const SizedBox(height: 16),
                    ],
                    if (!_isRunning && _steps.isNotEmpty) ...[
                      const Text('Diagnostic Steps',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ..._steps.map(_stepCard),
                      const SizedBox(height: 16),
                      _howToCard(),
                      const SizedBox(height: 12),
                      _quickFixCard(),
                    ],
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

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(10),
          border: outlined ? Border.all(color: Colors.black26) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: outlined ? Colors.black54 : Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: outlined ? Colors.black54 : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kErrorRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.close, color: kErrorRed, size: 18),
              SizedBox(width: 8),
              Text('CANNOT REACH API',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kErrorRed)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: kAmber, size: 14),
                    SizedBox(width: 6),
                    Text('Solution:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kAmber)),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Network error. Possible causes: 1. No internet connection 2. CORS issue 3. API endpoint down 4. Firewall/proxy blocking request. SOLUTION: Check internet connection and try again.',
                  style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard(_DiagStep step) {
    final isPassed = step.passed == true;
    final isFailed = step.passed == false;
    final isPending = step.passed == null;

    Color borderColor = Colors.grey.shade200;
    Color bgColor = Colors.white;
    Color titleColor = Colors.black87;

    if (isPassed) {
      bgColor = const Color(0xFFE8F5E9);
      borderColor = kPrimaryGreen.withOpacity(0.3);
      titleColor = kPrimaryGreen;
    } else if (isFailed) {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade200;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step ${step.number}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black38,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(step.title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isFailed ? kErrorRed : titleColor)),
                if (step.details != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Details:\n${step.details}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.black54,
                          height: 1.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isPending)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: isPassed
                  ? const Icon(Icons.check_circle,
                      color: kPrimaryGreen, size: 20)
                  : const Icon(Icons.warning_amber_rounded,
                      color: kAmber, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _howToCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🛠️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('How to Use This Tool',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            'Click "Run Diagnostics" to check your authentication status',
            'Review each step to see what\'s working and what\'s not',
            'Follow the suggested solutions for any errors',
            'Use "Clear Storage" if token is corrupted or expired',
            'Use "Sign Out" to log out and start fresh',
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(color: Colors.black45)),
                    Expanded(
                        child: Text(tip,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                height: 1.4))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _quickFixCard() {
    final fixes = [
      ('Token Expired', '→ Sign out and sign in again'),
      ('User Profile Not Found (404)',
          '→ Profile wasn\'t created during signup. Try creating a new account.'),
      ('Invalid Token (401)', '→ Clear storage and sign in again'),
      ('Network Error', '→ Check internet connection'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🔧', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('Common Issues & Quick Fixes',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...fixes.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.$1,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(f.$2,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}