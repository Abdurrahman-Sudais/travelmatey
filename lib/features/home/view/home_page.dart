import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/bookings/view/bookings_page.dart';
import 'package:travelmateeee/features/home/view/driver_home_page.dart';
import 'package:travelmateeee/features/rides/view/search_page.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/core/base/active_role.dart';

// ─── Global role notifier ─────────────────────────────────────────────────────

/// Swap between rider and driver mode from anywhere in the app.
final ValueNotifier<ActiveRole> activeRoleNotifier =
    ValueNotifier<ActiveRole>(ActiveRole.rider);

// ─── Role-aware shell ─────────────────────────────────────────────────────────

/// Top-level widget that listens to [activeRoleNotifier] and swaps
/// between the rider [HomePage] and the [DriverHomePage].
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
  final String from;
  final String to;
  final String price;
  final int available;

  const PopularRoute({
    required this.from,
    required this.to,
    required this.price,
    required this.available,
  });
}

// ─── Rider Home ───────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PopularRoute> popularRoutes = const [
    PopularRoute(from: 'Lagos', to: 'Abuja', price: '₦25,000', available: 12),
    PopularRoute(from: 'Abuja', to: 'Port Harcourt', price: '₦30,000', available: 8),
    PopularRoute(from: 'Lagos', to: 'Ibadan', price: '₦8,000', available: 15),
    PopularRoute(from: 'Abuja', to: 'Kaduna', price: '₦12,000', available: 6),
  ];

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
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
                    ...popularRoutes.map(_popularRouteCard),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavBar(current: AppTab.home),
            ),
          ],
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
                'Find Your Ride',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Where are you going today?',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        Stack(
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
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_none, color: Colors.black87),
            ),
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
                child: const Text(
                  '1',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
      onTap: () => _goTo(const SearchPage()),
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: kPrimaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGreen.withOpacity(0.25),
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
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            const Text(
              'Search Rides',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold));
  }

  Widget _activityRow() {
    return Row(
      children: [
        Expanded(
          child: _activityCard(
            icon: Icons.assignment_outlined,
            iconColor: kPrimaryBlue,
            value: '12',
            label: 'Bookings',
            onTap: () => _goTo(const BookingsPage()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _activityCard(
            icon: Icons.check_circle_outline,
            iconColor: kPrimaryGreen,
            value: '10',
            label: 'Completed',
            onTap: () => _goTo(const BookingsPage()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _activityCard(
            icon: Icons.star_outline,
            iconColor: kAmber,
            value: '4.9',
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _popularRouteCard(PopularRoute route) {
    return GestureDetector(
      onTap: () => _goTo(const SearchPage()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.black38),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      route.to,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
