import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/emergency_sos.dart';
import '../widgets/app_bottom_nav.dart';

enum _RideStatus { upcoming, inProgress, completed }

class _RideItem {
  final String from;
  final String to;
  final String departure;
  final String seats;
  final String earnings;
  final _RideStatus status;

  const _RideItem({
    required this.from,
    required this.to,
    required this.departure,
    required this.seats,
    required this.earnings,
    required this.status,
  });
}

class MyRidesPage extends StatefulWidget {
  const MyRidesPage({super.key});

  @override
  State<MyRidesPage> createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _upcoming = const [
    _RideItem(
      from: 'Abuja',
      to: 'Lagos',
      departure: 'Dec 25, 2024 · 10:30',
      seats: '4/6 seats',
      earnings: '₦100,000',
      status: _RideStatus.upcoming,
    ),
    _RideItem(
      from: 'Lagos',
      to: 'Port Harcourt',
      departure: 'Dec 27, 2024 · 08:00',
      seats: '2/4 seats',
      earnings: '₦70,000',
      status: _RideStatus.upcoming,
    ),
  ];

  final _inProgress = const [
    _RideItem(
      from: 'Kano',
      to: 'Abuja',
      departure: 'Jun 13, 2026 · 06:00',
      seats: '3/4 seats',
      earnings: '₦45,000',
      status: _RideStatus.inProgress,
    ),
  ];

  final _completed = const [
    _RideItem(
      from: 'Kaduna',
      to: 'Lagos',
      departure: 'Jun 6, 2026 · 07:00',
      seats: '4/4 seats',
      earnings: '₦95,000',
      status: _RideStatus.completed,
    ),
    _RideItem(
      from: 'Abuja',
      to: 'Enugu',
      departure: 'May 28, 2026 · 09:00',
      seats: '3/4 seats',
      earnings: '₦60,000',
      status: _RideStatus.completed,
    ),
  ];

  // Summary stats
  int get _totalEarningsK => 450;
  int get _upcomingCount => _upcoming.length + _inProgress.length;
  int get _requestsCount => 7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                          "My Rides",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        _summaryRow(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // Tab bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: kPrimaryGreen,
                      indicatorWeight: 2.5,
                      labelColor: kPrimaryGreen,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      unselectedLabelStyle:
                          const TextStyle(fontSize: 13),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: "Upcoming"),
                        Tab(text: "In Progress"),
                        Tab(text: "Completed"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _rideList(_upcoming),
                        _rideList(_inProgress),
                        _rideList(_completed),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: _postRideBar()),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text("Back",
              style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _summaryRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            label: "Total Earnings",
            value: "₦${_totalEarningsK}k",
            valueColor: kPrimaryGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: "Upcoming",
            value: "$_upcomingCount",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: "Requests",
            value: "$_requestsCount",
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      {required String label,
      required String value,
      Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rideList(List<_RideItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text("No rides here yet.",
            style: TextStyle(color: Colors.black38)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: items.length,
      itemBuilder: (_, i) => _rideCard(items[i]),
    );
  }

  Widget _rideCard(_RideItem item) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dotLabel(item.from, kPrimaryGreen),
                    const SizedBox(height: 6),
                    _dotLabel(item.to, kErrorRed),
                  ],
                ),
                const Spacer(),
                _statusBadge(item.status),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF2F2F2)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _detailRow(Icons.schedule_outlined,
                    "Departure:", item.departure),
                const SizedBox(height: 8),
                _detailRow(Icons.people_outline, "Riders:", item.seats),
                const SizedBox(height: 8),
                _detailRow(Icons.payments_outlined,
                    "Earnings:", item.earnings,
                    valueColor: kPrimaryGreen),
                const SizedBox(height: 14),
                _actionRow(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotLabel(String text, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statusBadge(_RideStatus status) {
    final label = status == _RideStatus.upcoming
        ? "Upcoming"
        : status == _RideStatus.inProgress
            ? "In Progress"
            : "Completed";
    final color = status == _RideStatus.upcoming
        ? kPrimaryBlue
        : status == _RideStatus.inProgress
            ? kAmber
            : kPrimaryGreen;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.black45),
        const SizedBox(width: 6),
        Text(label,
            style:
                const TextStyle(fontSize: 12.5, color: Colors.black54)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87),
        ),
      ],
    );
  }

  Widget _actionRow(_RideItem item) {
    if (item.status == _RideStatus.completed) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          child: _chip("View Details", kPrimaryBlue, filled: false),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _chip(
            item.status == _RideStatus.inProgress
                ? "Track Ride"
                : "Requests",
            kPrimaryGreen,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, Color color, {required bool filled}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _postRideBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                // TODO: navigate to Post New Ride
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "+ Post New Ride",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const AppBottomNavBar(current: AppTab.secondary),
          ],
        ),
      ),
    );
  }

}