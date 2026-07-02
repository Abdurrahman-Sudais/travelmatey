import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class _Referral {
  final String name;
  final String date;
  final String? earned;
  final bool pending;

  const _Referral({
    required this.name,
    required this.date,
    this.earned,
    this.pending = false,
  });
}

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  bool _loading = true;
  String _code = '';
  String _referralLink = '';
  String _totalReferrals = '0';
  String _totalEarned = '₦0';
  List<_Referral> _referrals = [];

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    try {
      final json = await ApiService.instance.get(ApiEndpoints.referral);
      final referrals = json['referrals'] as List? ??
          json['referredUsers'] as List? ??
          json['data']?['referrals'] as List? ??
          const [];
      setState(() {
        _code = json['code']?.toString() ??
            json['referralCode']?.toString() ??
            json['referral_code']?.toString() ??
            '';
        _referralLink = json['link']?.toString() ??
            json['referralLink']?.toString() ??
            json['referral_link']?.toString() ??
            '';
        _totalReferrals = (json['totalReferrals'] ??
                json['total_referrals'] ??
                referrals.length)
            .toString();
        final earned = json['totalEarned'] ?? json['total_earned'];
        _totalEarned = earned != null ? '₦$earned' : '₦0';
        _referrals = referrals.map((item) {
          final map = item as Map<String, dynamic>;
          final pending = map['pending'] as bool? ??
              map['status']?.toString().toLowerCase() == 'pending';
          return _Referral(
            name: map['name']?.toString() ?? 'User',
            date: map['date']?.toString() ??
                map['createdAt']?.toString() ??
                map['created_at']?.toString() ??
                '',
            earned: pending
                ? null
                : '+₦${map['earned'] ?? map['reward'] ?? '0'}',
            pending: pending,
          );
        }).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimaryBlue),
                )
              : RefreshIndicator(
                  onRefresh: _loadReferralData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                    // Hero banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.group_outlined,
                                color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 14),
                          const Text('Invite Friends, Earn Rewards',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                              'Get ₦2,000 for every friend who completes their first ride',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _statBox(_totalReferrals, 'Total Referrals'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statBox(_totalEarned, 'Total Earned'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Code card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Referral Code',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: kPrimaryBlue,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _code.isNotEmpty ? _code : '—',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryBlue,
                                        letterSpacing: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _code.isEmpty
                                    ? null
                                    : () {
                                        Clipboard.setData(
                                            ClipboardData(text: _code));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Code copied to clipboard'),
                                          ),
                                        );
                                      },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: kPrimaryBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.copy,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.share_outlined,
                                  label: 'Share Link',
                                  filled: true,
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.link,
                                  label: 'Copy Link',
                                  filled: false,
                                  onTap: () {
                                    final link = _referralLink.isNotEmpty
                                        ? _referralLink
                                        : _code;
                                    if (link.isEmpty) return;
                                    Clipboard.setData(
                                        ClipboardData(text: link));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Link copied to clipboard'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // How it works
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('How It Works',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _howItWorksItem(
                            icon: Icons.share_outlined,
                            title: 'Share Your Code',
                            subtitle: 'Send your referral code to friends and family',
                          ),
                          const SizedBox(height: 12),
                          _howItWorksItem(
                            icon: Icons.person_add_outlined,
                            title: 'Friend Joins & Rides',
                            subtitle: 'They get ₦1,000 bonus on their first ride',
                          ),
                          const SizedBox(height: 12),
                          _howItWorksItem(
                            icon: Icons.monetization_on_outlined,
                            title: 'You Earn Rewards',
                            subtitle: 'Get ₦2,000 credited to your wallet',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Referrals list
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Referrals',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 14),
                          if (_referrals.isEmpty)
                            const Text(
                              'No referrals yet. Share your code to get started.',
                              style: TextStyle(fontSize: 13, color: Colors.black45),
                            )
                          else
                            ..._referrals.map(_referralItem),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // T&C
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Text(
                        'Terms & Conditions: Referral rewards are credited after your friend completes their first ride. '
                        'Maximum of 50 referrals per month. Rewards may take up to 24 hours to reflect in your wallet.',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? kPrimaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: kPrimaryBlue),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: filled ? Colors.white : kPrimaryBlue, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: filled ? Colors.white : kPrimaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _howItWorksItem(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            gradient: kPrimaryGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _referralItem(_Referral referral) {
    final initials = referral.name.split(' ').map((e) => e[0]).take(1).join();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: kPrimaryGradient,
              shape: BoxShape.circle,
            ),
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(referral.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(referral.date,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
          if (referral.pending)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Pending',
                  style: TextStyle(
                      color: kAmber,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            )
          else
            Text(referral.earned ?? '',
                style: const TextStyle(
                    color: kPrimaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
        ],
      ),
    );
  }
}