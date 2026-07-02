import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'my_rides_page.dart';
import 'edit_ride_page.dart';
import 'trip_in_progress_page.dart';

class RideDetailsPage extends StatelessWidget {
  final RideItem ride;

  const RideDetailsPage({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final isInProgress = ride.status == RideStatus.inProgress;
    final isCompleted = ride.status == RideStatus.completed;

    final confirmedRiders = [
      _RiderInfo(
        initials: 'AJ',
        color: const Color(0xFFE57373),
        name: 'Adebayo Johnson',
        rating: 4.8,
        seats: '2 seats',
        pickup: 'Utako',
        dropoff: 'Ikeja',
      ),
      _RiderInfo(
        initials: 'CO',
        color: const Color(0xFF4DB6AC),
        name: 'Chioma Okafor',
        rating: 5.0,
        seats: '1 seat',
        pickup: 'Market, Abuja',
        dropoff: 'Ojota',
      ),
      _RiderInfo(
        initials: 'IM',
        color: const Color(0xFF7986CB),
        name: 'Ibrahim Musa',
        rating: 4.9,
        seats: '3 seats',
        pickup: 'Jabi, Abuja',
        dropoff: 'Ikeja',
      ),
    ];

    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(context),
                    const SizedBox(height: 12),
                    const Text(
                      'Ride Details',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Route Information
                    _sectionCard(
                      title: 'Route Information',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _dotLabel(ride.from, kPrimaryGreen),
                                    const SizedBox(height: 6),
                                    _dotLabel(ride.to, kErrorRed),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    ride.departure.split('·').first.trim(),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54),
                                  ),
                                  Text(
                                    ride.departure.contains('·')
                                        ? ride.departure
                                            .split('·')
                                            .last
                                            .trim()
                                        : '',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Pickup Points:',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54)),
                                const SizedBox(height: 2),
                                const Text('Utako • Market, Abuja',
                                    style: TextStyle(fontSize: 13)),
                                const SizedBox(height: 8),
                                const Text('Drop-off Points:',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54)),
                                const SizedBox(height: 2),
                                const Text('Ikeja • Ojota • Berger',
                                    style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Booking Summary
                    _sectionCard(
                      title: 'Booking Summary',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: _summaryStatBox(
                                      'Confirmed Seats',
                                      '${ride.seats.split('/').first.trim()}/${ride.seats.split('/').last.replaceAll(RegExp(r'[^0-9]'), '').trim()}')),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _summaryStatBox(
                                      'Total Earnings', ride.earnings,
                                      valueColor: kPrimaryGreen)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: _summaryStatBox(
                                      'Price Per Seat', '₦25,000')),
                              const SizedBox(width: 10),
                              Expanded(
                                  child:
                                      _summaryStatBox('Available Seats', '0')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Vehicle & Amenities
                    _sectionCard(
                      title: 'Vehicle & Amenities',
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Vehicle:',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54)),
                              Text('Toyota Sienna',
                                  style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Color:',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54)),
                              Text('Grey',
                                  style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: ['AC', 'Music', 'Pets Allowed']
                                .map((a) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: kPrimaryBlue.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(a,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kPrimaryBlue)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirmed Riders
                    if (!isCompleted) ...[
                      _sectionCard(
                        title:
                            'Confirmed Riders (${confirmedRiders.length})',
                        child: Column(
                          children: confirmedRiders
                              .map((r) => _riderRow(r))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),

              // Bottom buttons
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isCompleted) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _outlineBtn(
                                  'Edit Ride',
                                  kPrimaryBlue,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            EditRidePage(ride: ride)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _outlineBtn(
                                  'Cancel Ride',
                                  kErrorRed,
                                  () => _confirmCancel(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (!isCompleted)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          TripInProgressPage(ride: ride)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                elevation: 4,
                                shadowColor:
                                    kPrimaryGreen.withValues(alpha: 0.3),
                              ),
                              child: Text(
                                isInProgress
                                    ? 'Track Ride'
                                    : 'Start Trip',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: Text(
            'Cancel the ride from ${ride.from} to ${ride.to}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, Keep')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to rides list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Ride cancelled'),
                    backgroundColor: Colors.redAccent),
              );
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text('Back',
              style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
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
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen)),
          const SizedBox(height: 12),
          child,
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
            decoration:
                BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _summaryStatBox(String label, String value,
      {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: Colors.black45)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _riderRow(_RiderInfo r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: r.color,
            child: Text(r.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(r.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 13, color: Colors.amber),
                    Text(r.rating.toString(),
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${r.seats}  •  ${r.pickup} → ${r.dropoff}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: kPrimaryGreen, shape: BoxShape.circle),
            child: const Icon(Icons.phone, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _outlineBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _RiderInfo {
  final String initials;
  final Color color;
  final String name;
  final double rating;
  final String seats;
  final String pickup;
  final String dropoff;

  const _RiderInfo({
    required this.initials,
    required this.color,
    required this.name,
    required this.rating,
    required this.seats,
    required this.pickup,
    required this.dropoff,
  });
}