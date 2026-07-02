import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/data/repositories/ride_repository.dart';
import 'ride_details_page.dart';
import 'post_ride_page.dart';
import 'trip_in_progress_page.dart';
import 'live_route_map.dart';

enum RideStatus { upcoming, inProgress, completed }

class RideItem {
  final String id;
  final String from;
  final String to;
  final String departure;
  final String seats;
  final String earnings;
  final RideStatus status;

  const RideItem({
    required this.id,
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
  final RideRepository _repo = createRideRepository();

  List<RideItem> _upcoming = [];
  List<RideItem> _inProgress = [];
  List<RideItem> _completed = [];

  int get _totalEarningsK => 450;
  int get _upcomingCount => _upcoming.length + _inProgress.length;
  int get _requestsCount => 7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    try {
      final rides = await _repo.getRides();
      final upcoming = <RideItem>[];
      final inProgress = <RideItem>[];
      final completed = <RideItem>[];

      for (var r in rides) {
        final earnings = r.pricePerSeat * r.totalSeats;
        final item = RideItem(
          id: r.id,
          from: r.from,
          to: r.to,
          departure: r.departureTime,
          seats: '${r.availableSeats}/${r.totalSeats} seats',
          earnings: '₦${earnings.toStringAsFixed(0)}',
          status: r.status == 'in_progress'
              ? RideStatus.inProgress
              : r.status == 'completed'
                  ? RideStatus.completed
                  : RideStatus.upcoming,
        );
        if (item.status == RideStatus.upcoming) {
          upcoming.add(item);
        } else if (item.status == RideStatus.inProgress) {
          inProgress.add(item);
        } else {
          completed.add(item);
        }
      }

      if (!mounted) return;
      setState(() {
        _upcoming = upcoming;
        _inProgress = inProgress;
        _completed = completed;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load rides: $e'), backgroundColor: kErrorRed),
      );
    } finally {
      // Intentionally left empty as _isLoading was removed
    }
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _summaryRow(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(fontSize: 13),
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
            Align(alignment: Alignment.bottomCenter, child: _postRideBar()),
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
          Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
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
          child: _summaryCard(label: "Upcoming", value: "$_upcomingCount"),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(label: "Requests", value: "$_requestsCount"),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
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

  Widget _rideList(List<RideItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No rides here yet.",
          style: TextStyle(color: Colors.black38),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: items.length,
      itemBuilder: (_, i) => _rideCard(items[i]),
    );
  }

  Widget _rideCard(RideItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                _detailRow(
                  Icons.schedule_outlined,
                  "Departure:",
                  item.departure,
                ),
                const SizedBox(height: 8),
                _detailRow(Icons.people_outline, "Riders:", item.seats),
                const SizedBox(height: 8),
                _detailRow(
                  Icons.payments_outlined,
                  "Earnings:",
                  item.earnings,
                  valueColor: kPrimaryGreen,
                ),
                const SizedBox(height: 14),
                _actionRow(item),
                if (item.status == RideStatus.inProgress) ...[
                  const SizedBox(height: 14),
                  LiveRouteMap(
                    origin: RoutePoint(label: item.from, lat: 6.6018, lng: 3.3515),
                    destination: RoutePoint(label: item.to, lat: 9.0765, lng: 7.4951),
                    onExpand: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripInProgressPage(ride: item),
                        ),
                      );
                    },
                  ),
                ],
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
        Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _statusBadge(RideStatus status) {
    final label = status == RideStatus.upcoming
        ? "Upcoming"
        : status == RideStatus.inProgress
        ? "In Progress"
        : "Completed";
    final color = status == RideStatus.upcoming
        ? kPrimaryBlue
        : status == RideStatus.inProgress
        ? kAmber
        : kPrimaryGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.black45),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _actionRow(RideItem item) {
    if (item.status == RideStatus.completed) {
      return SizedBox(
        width: double.infinity,
        child: _chip(
          "View Details",
          kPrimaryBlue,
          filled: false,
          onTap: () => _openDetails(item),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _chip(
            "View Details",
            kPrimaryBlue,
            filled: false,
            onTap: () => _openDetails(item),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _chip(
            item.status == RideStatus.inProgress ? "Track Ride" : "Requests",
            kPrimaryGreen,
            filled: true,
            onTap: () {
              if (item.status == RideStatus.inProgress) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripInProgressPage(ride: item),
                  ),
                );
              } else {
                _openDetails(item);
              }
            },
          ),
        ),
      ],
    );
  }

  void _openDetails(RideItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RideDetailsPage(ride: item)),
    ).then((_) {
      // Refresh in case a ride was cancelled from details page
      setState(() {});
    });
  }

  Widget _chip(
    String label,
    Color color, {
    required bool filled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostRidePage()),
                );
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
                      color: kPrimaryGreen.withValues(alpha: 0.3),
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
                      "Post New Ride",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}