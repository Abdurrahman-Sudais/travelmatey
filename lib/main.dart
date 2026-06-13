import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'widgets/emergency_sos.dart';

void main() => runApp(
  DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        // Chain DevicePreview's builder, then overlay the global SOS button
        // on top of whatever screen is currently showing.
        final previewed = DevicePreview.appBuilder(context, child);
        return Stack(children: [previewed, const GlobalEmergencySosOverlay()]);
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEBF6FD),
          brightness: Brightness.light,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// Shared colors / tokens
const Color kBackground = Color(0xFFEBF3FB);
const Color kPrimaryGreen = Color(0xFF008000);
const Color kPrimaryBlue = Color(0xFF0b6cb9);
const Color kErrorRed = Color(0xFFFF4B4B);
const Color kAmber = Color(0xFFF59E0B);
const Gradient kPrimaryGradient = LinearGradient(
  colors: [kPrimaryBlue, kPrimaryGreen],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class PopularRoute {
  final String from;
  final String to;
  final String price;
  final int available;

  PopularRoute({
    required this.from,
    required this.to,
    required this.price,
    required this.available,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PopularRoute> popularRoutes = [
    PopularRoute(from: 'Lagos', to: 'Abuja', price: '₦25,000', available: 12),
    PopularRoute(
      from: 'Abuja',
      to: 'Port Harcourt',
      price: '₦30,000',
      available: 8,
    ),
    PopularRoute(from: 'Lagos', to: 'Ibadan', price: '₦8,000', available: 15),
    PopularRoute(from: 'Abuja', to: 'Kaduna', price: '₦12,000', available: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Bottom navigation bar
          Align(alignment: Alignment.bottomCenter, child: _bottomNavBar()),
        ],
      ),
    );
  }

  // Header: "Find Your Ride" + subtitle + notification bell with badge
  Widget _appbarRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Find Your Ride",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Where are you going today?",
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
              child: const Icon(
                Icons.notifications_none,
                color: Colors.black87,
              ),
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
                  "1",
                  style: TextStyle(
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

  // Blue -> green gradient "Search Rides" bar
  Widget _searchBar() {
    return Container(
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
            "Search Rides",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  // Bookings / Completed / Rating cards
  Widget _activityRow() {
    return Row(
      children: [
        Expanded(
          child: _activityCard(
            icon: Icons.assignment_outlined,
            iconColor: kPrimaryBlue,
            value: "12",
            label: "Bookings",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _activityCard(
            icon: Icons.check_circle_outline,
            iconColor: kPrimaryGreen,
            value: "10",
            label: "Completed",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _activityCard(
            icon: Icons.star_outline,
            iconColor: kAmber,
            value: "4.9",
            label: "Rating",
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
  }) {
    return Container(
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
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // "Lagos > Abuja   ₦25,000 / 12 available" row card
  Widget _popularRouteCard(PopularRoute route) {
    return Container(
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.black38,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    route.to,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                "${route.available} available",
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bottom nav: Home | Bookings (badge) | Wallet | Chats | Profile
  Widget _bottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_filled, "Home", active: true),
              _navItem(Icons.calendar_month_outlined, "Bookings", badge: "2"),
              _navItem(Icons.account_balance_wallet_outlined, "Wallet"),
              _navItem(Icons.chat_bubble_outline, "Chats"),
              _navItem(Icons.person_outline, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label, {
    bool active = false,
    String? badge,
  }) {
    final color = active ? kPrimaryGreen : Colors.black54;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: color, size: 22),
            if (badge != null)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: kErrorRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}
