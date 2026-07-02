import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/data/repositories/user_repository.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/home/view/driver_home_page.dart';
import 'package:travelmateeee/features/profile/view/notifications_page.dart';
import 'package:travelmateeee/features/rides/view/search_page.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart'
    show switchToTab, AppTab;
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/core/base/active_role.dart';
import 'package:travelmateeee/shared/widgets/kyc_popup.dart';

// ─── Global role notifier ─────────────────────────────────────────────────────

final ValueNotifier<ActiveRole> activeRoleNotifier = ValueNotifier<ActiveRole>(
  ActiveRole.rider,
);

// ─── Role-aware shell ─────────────────────────────────────────────────────────

class RoleAwareHome extends StatelessWidget {
  const RoleAwareHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ActiveRole>(
      valueListenable: activeRoleNotifier,
      builder: (context, role, _) {
        if (role == ActiveRole.driver) return const DriverHomePage();
        return const HomePage();
      },
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class PopularRoute {
  final String id;
  final String from;
  final String to;
  final String price;
  final int available;

  const PopularRoute({
    this.id = '',
    required this.from,
    required this.to,
    required this.price,
    required this.available,
  });

  factory PopularRoute.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final priceStr = rawPrice is num
        ? '₦${rawPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
        : rawPrice?.toString() ?? '₦0';

    return PopularRoute(
      id: json['id']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      price: priceStr,
      available: json['availableSeats'] as int? ??
          json['available_seats'] as int? ??
          0,
    );
  }
}

// ─── Rider Home ───────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO: replace with real KYC status from your auth/user provider
  bool _kycCompleted = false;

  int _unreadNotifications = 0;

  List<PopularRoute> _popularRoutes = [];
  bool _loadingRoutes = true;
  bool _loadingActivity = true;
  String _bookingsCount = '—';
  String _completedCount = '—';
  String _ratingValue = '—';

  @override
  void initState() {
    super.initState();
    _loadPopularRoutes();
    _loadActivity();
    _loadKycStatus();
    _loadNotificationCount();
  }

  Future<void> _loadKycStatus() async {
    try {
      final user = await Get.find<UserRepository>().getCurrentUser();
      if (!mounted) return;
      setState(() => _kycCompleted = user.kycVerified);
    } catch (_) {}
  }

  Future<void> _loadNotificationCount() async {
    try {
      final data = await ApiService.instance.get('/notifications');
      final list = data['notifications'] as List? ?? data['data'] as List? ?? [];
      final unread = list.whereType<Map>().where((n) => n['isRead'] == false || n['read'] == false).length;
      if (!mounted) return;
      setState(() => _unreadNotifications = unread);
    } catch (_) {
      // silently fail — badge simply stays at 0
    }
  }

  Future<void> _loadPopularRoutes() async {
    try {
      final data = await ApiService.instance.get('/rides/popular');
      final rides = data['rides'] as List<dynamic>? ??
          data['data'] as List<dynamic>? ??
          [];
      if (!mounted) return;
      setState(() {
        _popularRoutes = rides
            .map((r) => PopularRoute.fromJson(r as Map<String, dynamic>))
            .toList();
        _loadingRoutes = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Silently fail — show empty state instead of error snackbar
      setState(() => _loadingRoutes = false);
    }
  }

  Future<void> _loadActivity() async {
    try {
      // Try the activity endpoint; fall back to booking count from /bookings/user/:id
      final userId = ApiService.instance.getUserId();
      Map<String, dynamic> data = {};
      try {
        data = await ApiService.instance.get('/user/activity');
      } catch (_) {
        // Endpoint may not exist — try to derive counts from bookings
        if (userId != null && userId.isNotEmpty) {
          try {
            final bookingsData =
                await ApiService.instance.get('/bookings/user/$userId');
            final list = bookingsData['bookings'] as List? ??
                bookingsData['data'] as List? ??
                [];
            final completed = list
                .whereType<Map>()
                .where((b) => b['status'] == 'completed')
                .length;
            data = {
              'bookings': list.length,
              'completed': completed,
            };
          } catch (_) {}
        }
      }
      if (!mounted) return;
      setState(() {
        _bookingsCount = (data['bookings'] ??
                data['totalBookings'] ??
                data['total_bookings'] ??
                0)
            .toString();
        _completedCount = (data['completed'] ??
                data['completedBookings'] ??
                data['completed_bookings'] ??
                0)
            .toString();
        final rating = data['rating'] ??
            data['averageRating'] ??
            data['average_rating'];
        _ratingValue = rating != null ? rating.toString() : '0';
        _loadingActivity = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Silently fail — show zeros rather than an error snackbar
      setState(() {
        _bookingsCount = '0';
        _completedCount = '0';
        _ratingValue = '0';
        _loadingActivity = false;
      });
    }
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Gate any action behind KYC. If KYC is complete, runs [action] directly.
  /// Otherwise shows KYC popup; if user completes KYC, marks done and re-runs.
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
                const SizedBox(height: 16),
                _searchBar(),
                const SizedBox(height: 20),
                _sectionTitle('Your Activity'),
                const SizedBox(height: 10),
                _activityRow(),
                const SizedBox(height: 20),
                _sectionTitle('Popular Routes'),
                const SizedBox(height: 10),
                if (_loadingRoutes)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: kPrimaryBlue),
                    ),
                  )
                else if (_popularRoutes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No popular routes yet',
                      style: TextStyle(color: kTextSecondary),
                    ),
                  )
                else
                  ..._popularRoutes.map(_popularRouteCard),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Your Ride',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Where are you going today?',
                style: TextStyle(fontSize: 13, color: kTextSecondary),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => _goTo(const NotificationsPage()),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: kNavShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.notifications_none, color: kTextPrimary),
              ),
            ),
            if (_unreadNotifications > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  height: 18,
                  width: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kErrorRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      onTap: () => _kycGated(() => _goTo(const SearchPage())),
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: kPrimaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGreen.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            const Text(
              'Search Rides',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: kTextPrimary,
      ),
    );
  }

  Widget _activityRow() {
    if (_loadingActivity) {
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
          child: _activityCard(
            icon: Icons.assignment_outlined,
            iconColor: kPrimaryBlue,
            value: _bookingsCount,
            label: 'Bookings',
            onTap: () => switchToTab(AppTab.secondary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _activityCard(
            icon: Icons.check_circle_outline,
            iconColor: kPrimaryGreen,
            value: _completedCount,
            label: 'Completed',
            onTap: () => switchToTab(AppTab.secondary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _activityCard(
            icon: Icons.star_outline,
            iconColor: kAmber,
            value: _ratingValue,
            label: 'Rating',
          ),
        ),
      ],
    );
  }

  Widget _activityCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kNavShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: kTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _popularRouteCard(PopularRoute route) {
    return GestureDetector(
      onTap: () => _kycGated(() => _goTo(const SearchPage())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kNavShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      route.from,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: kTextHint),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      route.to,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  route.price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${route.available} available',
                  style: TextStyle(fontSize: 11, color: kTextSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
