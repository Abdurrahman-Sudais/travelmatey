import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/emergency_sos.dart';

class _RideRecord {
  final String from;
  final String to;
  final String dateTime;
  final int seats;
  final String vehicle;
  final String amount;
  final bool completed;
  final double? rating;

  const _RideRecord({
    required this.from,
    required this.to,
    required this.dateTime,
    required this.seats,
    required this.vehicle,
    required this.amount,
    required this.completed,
    this.rating,
  });
}

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key});

  @override
  State<RideHistoryPage> createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  String _filter = 'All';

  final List<_RideRecord> _rides = const [
    _RideRecord(
      from: 'Abuja',
      to: 'Lagos',
      dateTime: 'Jan 18, 2026 • 6:00 AM',
      seats: 4,
      vehicle: 'Toyota Sienna - Grey',
      amount: '₦88,000',
      completed: true,
      rating: 4.9,
    ),
    _RideRecord(
      from: 'Lagos',
      to: 'Ibadan',
      dateTime: 'Jan 15, 2026 • 8:00 AM',
      seats: 2,
      vehicle: 'Honda Accord - Black',
      amount: '₦32,000',
      completed: true,
      rating: 5.0,
    ),
    _RideRecord(
      from: 'Abuja',
      to: 'Kaduna',
      dateTime: 'Jan 12, 2026 • 10:00 AM',
      seats: 1,
      vehicle: 'Toyota Camry - White',
      amount: '₦12,000',
      completed: false,
    ),
    _RideRecord(
      from: 'Lagos',
      to: 'Port Harcourt',
      dateTime: 'Dec 28, 2025 • 7:00 AM',
      seats: 3,
      vehicle: 'Toyota Sienna - Grey',
      amount: '₦120,000',
      completed: true,
      rating: 4.8,
    ),
    _RideRecord(
      from: 'Abuja',
      to: 'Enugu',
      dateTime: 'Dec 20, 2025 • 6:30 AM',
      seats: 2,
      vehicle: 'Honda Accord - Black',
      amount: '₦60,000',
      completed: true,
      rating: 4.7,
    ),
  ];

  List<_RideRecord> get _filtered {
    if (_filter == 'Completed') return _rides.where((r) => r.completed).toList();
    if (_filter == 'Cancelled') return _rides.where((r) => !r.completed).toList();
    return _rides;
  }

  int get _completedCount => _rides.where((r) => r.completed).length;
  int get _cancelledCount => _rides.where((r) => !r.completed).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
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
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statItem('${_rides.length}', 'Total Rides',
                              color: kPrimaryBlue),
                          _divider(),
                          _statItem('₦300k', 'Earnings', color: kPrimaryGreen),
                          _divider(),
                          _statItem('4.8 ★', 'Avg Rating', color: kAmber),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.black38, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search by location or rider...',
                                hintStyle: TextStyle(
                                    color: Colors.black38, fontSize: 13),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterTab('All (${_rides.length})'),
                          const SizedBox(width: 8),
                          _filterTab('Completed ($_completedCount)'),
                          const SizedBox(width: 8),
                          _filterTab('Cancelled ($_cancelledCount)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filtered.map(_rideCard),
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

  Widget _statItem(String value, String label, {required Color color}) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: Colors.grey.shade200);
  }

  Widget _filterTab(String label) {
    final key = label.split(' ').first;
    final selected = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _rideCard(_RideRecord ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ride.completed
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ride.completed ? '✓ Completed' : '✗ Cancelled',
                  style: TextStyle(
                    fontSize: 11,
                    color: ride.completed ? kPrimaryGreen : kErrorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (ride.rating != null)
                Row(
                  children: [
                    Text('${ride.rating}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: kAmber)),
                    const Icon(Icons.star, color: kAmber, size: 14),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(ride.from,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Expanded(
                  child: Container(height: 2, color: kPrimaryBlue)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_forward, size: 16, color: kPrimaryBlue),
              ),
              Expanded(child: Container(height: 2, color: kPrimaryBlue)),
              const SizedBox(width: 6),
              Text(ride.to,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),
          _detailRow('Date & Time', ride.dateTime),
          _detailRow('Seats Booked', '${ride.seats} seats'),
          _detailRow('Vehicle', ride.vehicle),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ride.completed ? 'Earnings' : 'Refunded',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              Text(ride.amount,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}