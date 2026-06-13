import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/emergency_sos.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_BookingItem> upcomingBookings = [
    _BookingItem(
      from: 'Abuja',
      to: 'Lagos',
      date: 'Mon, 16 Jun 2026',
      time: '8:00 AM',
      price: '₦25,000',
      driver: 'Adebayo Johnson',
      vehicle: 'Toyota Camry (Grey) · ABC-123-XY',
      status: _BookingStatus.upcoming,
    ),
    _BookingItem(
      from: 'Lagos',
      to: 'Ibadan',
      date: 'Wed, 18 Jun 2026',
      time: '2:00 PM',
      price: '₦8,000',
      driver: 'Chibueze Okonkwo',
      vehicle: 'Honda Accord (Black) · LND-456-AB',
      status: _BookingStatus.upcoming,
    ),
  ];

  final List<_BookingItem> pastBookings = [
    _BookingItem(
      from: 'Kaduna',
      to: 'Abuja',
      date: 'Fri, 6 Jun 2026',
      time: '7:30 AM',
      price: '₦12,000',
      driver: 'Musa Aliyu',
      vehicle: 'Toyota Corolla (White) · KDN-789-CD',
      status: _BookingStatus.completed,
    ),
    _BookingItem(
      from: 'Lagos',
      to: 'Port Harcourt',
      date: 'Sat, 31 May 2026',
      time: '6:00 AM',
      price: '₦30,000',
      driver: 'Emeka Nwosu',
      vehicle: 'Sienna Bus (Silver) · PHC-321-EF',
      status: _BookingStatus.completed,
    ),
    _BookingItem(
      from: 'Abuja',
      to: 'Kaduna',
      date: 'Mon, 19 May 2026',
      time: '9:00 AM',
      price: '₦12,000',
      driver: 'Ibrahim Sule',
      vehicle: 'Kia Sportage (Blue) · KDN-654-GH',
      status: _BookingStatus.cancelled,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _backButton(),
                        const SizedBox(height: 12),
                        const Text(
                          "My Bookings",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Manage your trips and reservations",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // Tab bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: kPrimaryGreen,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Upcoming"),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: kErrorRed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${upcomingBookings.length}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Tab(text: "Past Trips"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _bookingsList(upcomingBookings),
                        _bookingsList(pastBookings),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: _bottomNavBar()),
          ],
        ),
      ), // Scaffold
    ); // SosScaffold
  }

  Widget _backButton() {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _bookingsList(List<_BookingItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No bookings here yet.",
          style: TextStyle(color: Colors.black38),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      itemCount: items.length,
      itemBuilder: (_, i) => _bookingCard(items[i]),
    );
  }

  Widget _bookingCard(_BookingItem item) {
    final statusColor = item.status == _BookingStatus.completed
        ? kPrimaryGreen
        : item.status == _BookingStatus.cancelled
        ? kErrorRed
        : kPrimaryBlue;

    final statusLabel = item.status == _BookingStatus.completed
        ? "Completed"
        : item.status == _BookingStatus.cancelled
        ? "Cancelled"
        : "Upcoming";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Route header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      item.from,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.to,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _detailRow(
                  Icons.calendar_today_outlined,
                  "${item.date} · ${item.time}",
                ),
                const SizedBox(height: 8),
                _detailRow(Icons.person_outline, item.driver),
                const SizedBox(height: 8),
                _detailRow(Icons.directions_car_outlined, item.vehicle),
                const Divider(height: 20, color: Color(0xFFF0F0F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryGreen,
                      ),
                    ),
                    if (item.status == _BookingStatus.upcoming)
                      Row(
                        children: [
                          _actionChip("Cancel", kErrorRed),
                          const SizedBox(width: 8),
                          _actionChip(
                            "View Details",
                            kPrimaryBlue,
                            filled: true,
                          ),
                        ],
                      )
                    else if (item.status == _BookingStatus.completed)
                      _actionChip("Book Again", kPrimaryGreen, filled: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _actionChip(String label, Color color, {bool filled = false}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : color,
          ),
        ),
      ),
    );
  }

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
              _navItem(
                Icons.home_filled,
                "Home",
                onTap: () => Navigator.maybePop(context),
              ),
              _navItem(
                Icons.calendar_month_outlined,
                "Bookings",
                active: true,
                badge: "2",
              ),
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
    VoidCallback? onTap,
  }) {
    final color = active ? kPrimaryGreen : Colors.black54;
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}

enum _BookingStatus { upcoming, completed, cancelled }

class _BookingItem {
  final String from;
  final String to;
  final String date;
  final String time;
  final String price;
  final String driver;
  final String vehicle;
  final _BookingStatus status;

  const _BookingItem({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.price,
    required this.driver,
    required this.vehicle,
    required this.status,
  });
}
