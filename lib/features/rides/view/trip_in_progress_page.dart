import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'my_rides_page.dart';
import 'trip_summary_page.dart';

class TripInProgressPage extends StatefulWidget {
  final RideItem ride;
  const TripInProgressPage({super.key, required this.ride});

  @override
  State<TripInProgressPage> createState() => _TripInProgressPageState();
}

class _TripInProgressPageState extends State<TripInProgressPage> {
  // Track pickup/dropoff state per rider
  final List<_TripRider> _riders = [
    _TripRider(
      initials: 'AJ',
      color: const Color(0xFFE57373),
      name: 'Adebayo Johnson',
      seats: '2 seats',
      pickup: 'Utako',
      dropoff: 'Ikeja',
      isOnBoard: true,
      isDroppedOff: false,
    ),
    _TripRider(
      initials: 'CO',
      color: const Color(0xFF4DB6AC),
      name: 'Chioma Okafor',
      seats: '1 seat',
      pickup: 'Market, Abuja',
      dropoff: 'Ojota',
      isOnBoard: false,
      isDroppedOff: false,
    ),
    _TripRider(
      initials: 'GO',
      color: const Color(0xFFFF8A65),
      name: 'Grace Okonkwo',
      seats: '1 seat',
      pickup: 'Market, Abuja',
      dropoff: 'Ikeja',
      isOnBoard: false,
      isDroppedOff: false,
    ),
  ];

  int get _pickedUp => _riders.where((r) => r.isOnBoard || r.isDroppedOff).length;
  int get _droppedOff => _riders.where((r) => r.isDroppedOff).length;
  bool get _canComplete => _droppedOff == _riders.length;

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(context),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Trip in Progress',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${widget.ride.from} → ${widget.ride.to}',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: kAmber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kAmber.withOpacity(0.4)),
                          ),
                          child: Text('Active',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kAmber)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Live Route Map card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D5E), Color(0xFF1B5E40)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                            child: Row(
                              children: [
                                const Icon(Icons.navigation,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                const Text('Live Route Map',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.fullscreen,
                                      color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                const Text('ETA: 5:30 PM',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                const SizedBox(width: 12),
                                const Icon(Icons.trending_up,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                const Text('750 km total',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Fake map area
                          Container(
                            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('746 km remaining',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('● LIVE',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                // Route dots
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _routeDot(kPrimaryGreen, false, widget.ride.from),
                                        _routeConnector(true),
                                        _routeDot(kPrimaryGreen, true, ''),
                                        _routeConnector(false),
                                        _routeDot(Colors.grey, false, 'Lokoja'),
                                        _routeConnector(false),
                                        _routeDot(Colors.grey, false, widget.ride.to),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Progress card
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: kPrimaryGreen.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.bolt,
                                    color: kPrimaryGreen, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Approaching Utako, Abuja',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text('ETA: 5:30 PM  •  750 km',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black45)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Text('Trip Progress',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                              const Spacer(),
                              Text(
                                '${(_droppedOff / _riders.length * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: kPrimaryGreen,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _droppedOff / _riders.length,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF0F0F0),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kPrimaryGreen),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _statBox(
                                    'Picked Up',
                                    '$_pickedUp/${_riders.length}',
                                    Colors.black87),
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFEEEEEE)),
                              Expanded(
                                child: _statBox(
                                    'Dropped Off',
                                    '$_droppedOff/${_riders.length}',
                                    kPrimaryGreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Riders (${_riders.length})',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    ..._riders.asMap().entries.map((e) => _riderCard(e.key, e.value)),
                  ],
                ),
              ),

              // Bottom buttons
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showEmergency(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Emergency',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _canComplete
                                    ? () => _completeTrip(context)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _canComplete
                                      ? kPrimaryGreen
                                      : Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text('Complete',
                                    style: TextStyle(
                                        color: _canComplete
                                            ? Colors.white
                                            : Colors.grey.shade500,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
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

  Widget _routeDot(Color color, bool hasCheck, String label) {
    return Column(
      children: [
        Container(
          width: hasCheck ? 28 : 14,
          height: hasCheck ? 28 : 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: hasCheck
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 9, color: Colors.black54)),
        ]
      ],
    );
  }

  Widget _routeConnector(bool completed) {
    return Expanded(
      child: Container(
        height: 3,
        color: completed ? kPrimaryGreen : Colors.grey.shade300,
      ),
    );
  }

  Widget _statBox(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black45)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor)),
      ],
    );
  }

  Widget _riderCard(int index, _TripRider rider) {
    final Color borderColor = rider.isDroppedOff
        ? kPrimaryGreen.withOpacity(0.3)
        : rider.isOnBoard
            ? kPrimaryGreen.withOpacity(0.5)
            : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: rider.color,
                  child: Text(rider.initials,
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
                      Text(rider.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(rider.seats,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black45)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                  color: kPrimaryGreen,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(rider.pickup,
                              style: const TextStyle(fontSize: 11)),
                          const Icon(Icons.arrow_forward,
                              size: 11, color: Colors.black45),
                          Text(rider.dropoff,
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusChip(rider),
              ],
            ),
            const SizedBox(height: 12),
            if (!rider.isDroppedOff) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        if (rider.isOnBoard) {
                          _riders[index].isDroppedOff = true;
                          _riders[index].isOnBoard = false;
                        } else {
                          _riders[index].isOnBoard = true;
                        }
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            rider.isOnBoard ? kPrimaryGreen : kPrimaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        rider.isOnBoard ? 'Mark Dropped Off' : 'Mark Picked Up',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      rider.isOnBoard ? Icons.chat_bubble_outline : Icons.phone_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: kPrimaryGreen, size: 16),
                    const SizedBox(width: 6),
                    Text('Dropped Off',
                        style: TextStyle(
                            color: kPrimaryGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(_TripRider rider) {
    if (rider.isDroppedOff) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: kPrimaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('Done',
            style: TextStyle(
                fontSize: 10,
                color: kPrimaryGreen,
                fontWeight: FontWeight.w600)),
      );
    }
    if (rider.isOnBoard) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: kPrimaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('On Board',
            style: TextStyle(
                fontSize: 10,
                color: kPrimaryGreen,
                fontWeight: FontWeight.w600)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('Waiting',
          style: TextStyle(
              fontSize: 10, color: kAmber, fontWeight: FontWeight.w600)),
    );
  }

  void _showEmergency(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text(
            'This will alert emergency contacts and authorities. Proceed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Emergency alert sent!'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send Alert',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _completeTrip(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripSummaryPage(
          from: widget.ride.from,
          to: widget.ride.to,
          date: 'Dec 26, 2025',
          startTime: '10:30 AM',
          endTime: '5:45 PM',
          duration: '5h 15m',
          distance: '750 KM',
          totalFare: '₦150,000',
          platformFee: '₦7,500',
          netEarning: '₦ 142,500',
          riders: defaultTripRiders(),
        ),
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
          Text('Back', style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _TripRider {
  final String initials;
  final Color color;
  final String name;
  final String seats;
  final String pickup;
  final String dropoff;
  bool isOnBoard;
  bool isDroppedOff;

  _TripRider({
    required this.initials,
    required this.color,
    required this.name,
    required this.seats,
    required this.pickup,
    required this.dropoff,
    required this.isOnBoard,
    required this.isDroppedOff,
  });
}