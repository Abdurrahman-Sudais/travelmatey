import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'trip_completed_page.dart';

class TripSummaryPage extends StatefulWidget {
  final String from;
  final String to;
  final String date;
  final String startTime;
  final String endTime;
  final String duration;
  final String distance;
  final String totalFare;
  final String platformFee;
  final String netEarning;
  final List<RaterRider> riders;

  const TripSummaryPage({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distance,
    required this.totalFare,
    required this.platformFee,
    required this.netEarning,
    required this.riders,
  });

  @override
  State<TripSummaryPage> createState() => _TripSummaryPageState();
}

class _TripSummaryPageState extends State<TripSummaryPage> {
  late final List<double> _ratings;

  @override
  void initState() {
    super.initState();
    _ratings = List.filled(widget.riders.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(context),
                    const SizedBox(height: 16),
                    const Text(
                      'Trip Summary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Trip Details
                    _card(
                      title: 'Trip Details',
                      child: Column(
                        children: [
                          _detailRow2(
                            'Date',
                            widget.date,
                            'Duration',
                            widget.duration,
                          ),
                          const SizedBox(height: 12),
                          _detailRow2(
                            'Start Time',
                            widget.startTime,
                            'End Time',
                            widget.endTime,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text(
                                'Total Distance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                widget.distance,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Earning Breakdown
                    _card(
                      title: 'Earning Breakdown',
                      child: Column(
                        children: [
                          _earningRow(
                            'Total Fare',
                            widget.totalFare,
                            Colors.black87,
                          ),
                          const SizedBox(height: 10),
                          _earningRow(
                            'Platform Fee (5%)',
                            '- ${widget.platformFee}',
                            kErrorRed,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Net Earning',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                widget.netEarning,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Rate Your Riders
                    _card(
                      title: 'Rate Your Riders',
                      child: Column(
                        children: widget.riders.asMap().entries.map((e) {
                          final i = e.key;
                          final r = e.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: r.color,
                                  child: Text(
                                    r.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    r.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (star) {
                                    return GestureDetector(
                                      onTap: () => setState(
                                        () => _ratings[i] = star + 1.0,
                                      ),
                                      child: Icon(
                                        star < _ratings[i]
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: kAmber,
                                        size: 22,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Submit button
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TripCompletedPage(
                                    netEarning: widget.netEarning,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Submit & Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _card({required String title, required Widget child}) {
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _detailRow2(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l1,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 2),
              Text(
                v1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l2,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 2),
              Text(
                v2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _earningRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class RaterRider {
  final String initials;
  final Color color;
  final String name;

  const RaterRider({
    required this.initials,
    required this.color,
    required this.name,
  });
}

// Helper to build default riders list for the summary page
List<RaterRider> defaultTripRiders() => const [
  RaterRider(
    initials: 'AJ',
    color: Color(0xFFE57373),
    name: 'Adebayo Johnson',
  ),
  RaterRider(initials: 'CO', color: Color(0xFF4DB6AC), name: 'Chioma Okafor'),
  RaterRider(initials: 'IM', color: Color(0xFF7986CB), name: 'Ibrahim Musa'),
];
