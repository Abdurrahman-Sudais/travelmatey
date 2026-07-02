import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/features/rides/view/post_ride_page.dart';
import 'package:travelmateeee/features/rides/view/my_rides_page.dart';
import 'package:travelmateeee/features/wallet/view/wallet_page.dart';
import 'package:travelmateeee/features/profile/view/notifications_page.dart';
import 'package:travelmateeee/data/repositories/user_repository.dart';
import 'package:travelmateeee/data/repositories/wallet_repository.dart';
import 'package:travelmateeee/shared/widgets/kyc_popup.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool _kycCompleted = false;
  bool _loadingStats = true;
  String _earnings = '—';
  String _trips = '—';
  String _rating = '—';
  String _walletBalance = '—';
  // ignore: prefer_final_fields — updated via setState in _loadStats
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadKycStatus();
    _loadWalletBalance();
  }

  Future<void> _loadKycStatus() async {
    try {
      final user = await Get.find<UserRepository>().getCurrentUser();
      if (!mounted) return;
      setState(() => _kycCompleted = user.kycVerified);
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final userId = AuthService.instance.currentUser?.id ??
          ApiService.instance.getUserId();
      if (userId != null && userId.isNotEmpty) {
        final stats =
            await ApiService.instance.get(ApiEndpoints.profileStats(userId));
        final earnings = stats['totalEarnings'] ??
            stats['total_earnings'] ??
            stats['earnings'];
        final trips = stats['totalTrips'] ??
            stats['total_trips'] ??
            stats['trips'];
        final rating = stats['rating'] ??
            stats['averageRating'] ??
            stats['average_rating'];
        if (mounted) {
          setState(() {
            _earnings = _formatEarnings(earnings);
            _trips = trips?.toString() ?? '0';
            _rating = rating?.toString() ?? '0';
            _loadingStats = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingStats = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadWalletBalance() async {
    try {
      final wallet = await Get.find<WalletRepository>().getWallet();
      if (mounted) {
        setState(() => _walletBalance = _formatEarnings(wallet.balance));
      }
    } catch (_) {
      // Non-critical — keep showing '—'
    }
  }

  String _formatEarnings(dynamic value) {
    if (value == null) return '₦0';
    final amount = value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    if (amount >= 1000000) return '₦${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '₦${(amount / 1000).toStringAsFixed(0)}k';
    return '₦${amount.toStringAsFixed(0)}';
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _kycGated(VoidCallback action) async {
    if (_kycCompleted) {
      action();
      return;
    }
    final verified = await showKycPopup(context);
    if (verified == true) {
      setState(() => _kycCompleted = true);
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appbarRow(),
                const SizedBox(height: 20),
                _statsRow(),
                const SizedBox(height: 20),
                _postNewRideButton(),
                const SizedBox(height: 20),
                _quickActionsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appbarRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back!",
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Ready to hit the road?",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _goTo(const NotificationsPage()),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_none,
                    color: Colors.black87),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: _notificationCount > 0
                    ? Container(
                        height: 18,
                        width: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kErrorRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          _notificationCount > 9
                              ? '9+'
                              : '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statsRow() {
    if (_loadingStats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: kPrimaryBlue),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: "Total Earnings",
            value: _earnings,
            valueColor: kPrimaryGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(label: "Trips", value: _trips),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: "Rating",
            value: _rating,
            showStar: true,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    Color? valueColor,
    bool showStar = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black87,
                ),
              ),
              if (showStar) ...[
                const SizedBox(width: 3),
                const Icon(Icons.star, color: kAmber, size: 14),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _postNewRideButton() {
    return InkWell(
      onTap: () => _kycGated(() => _goTo(const PostRidePage())),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kPrimaryGreen,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "Post New Ride",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _quickActionCard(
            icon: Icons.directions_car_outlined,
            iconColor: kPrimaryBlue,
            title: "My Rides",
            subtitle: "View all trips",
            onTap: () => _goTo(const MyRidesPage()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionCard(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: kPrimaryGreen,
            title: "Wallet",
            subtitle: _walletBalance,
            onTap: () => _goTo(const WalletPage()),
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}