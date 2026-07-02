import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/features/bookings/view/request_sent_page.dart';
import 'package:travelmateeee/data/repositories/booking_repository.dart';

class RideListingDetailsPage extends StatefulWidget {
  final String rideId;
  final String driverName;
  final String currentLocation;
  final String destination;
  final String price;
  final String date;
  final String time;
  final double driverRating;
  final int availableSeats;

  const RideListingDetailsPage({
    super.key,
    required this.rideId,
    required this.driverName,
    required this.currentLocation,
    required this.destination,
    required this.price,
    required this.date,
    required this.time,
    this.driverRating = 0.0,
    this.availableSeats = 1,
  });

  @override
  State<RideListingDetailsPage> createState() => _RideListingDetailsPageState();
}

class _RideListingDetailsPageState extends State<RideListingDetailsPage> {
  bool _booking = false;

  Future<void> _confirmBooking() async {
    setState(() => _booking = true);
    try {
      await Get.find<BookingRepository>().createBooking(widget.rideId);
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RequestSentPage()),
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Booking Failed',
        e.toString(),
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context),
                const SizedBox(height: 16),
                _driverHeader(),
                const SizedBox(height: 18),
                const Text(
                  'Bio',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.driverName} is a TravelMate verified driver on this route.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _vehicleChips(),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ride Details',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '(${widget.date})',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black45),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _rideDetailsBox(),
                const SizedBox(height: 14),
                _pickupTimeRow(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    const Text('Price: ',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryBlue,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.availableSeats} seat${widget.availableSeats == 1 ? '' : 's'} left',
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _booking ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      disabledBackgroundColor: Colors.black38,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _booking
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Book a ride',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left, size: 22, color: Colors.black87),
              Text('Back', style: TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, size: 24, color: Colors.black87),
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kErrorRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _driverHeader() {
    final rating = widget.driverRating;
    final fullStars = rating.floor().clamp(0, 5);
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFE5E5E5),
          child: Icon(Icons.person, size: 30, color: Colors.black38),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.driverName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                'TravelMate Verified Driver',
                style: TextStyle(fontSize: 12, color: kPrimaryBlue),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < fullStars ? Icons.star : Icons.star_border,
                      size: 14,
                      color: kAmber,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating > 0 ? rating.toStringAsFixed(1) : 'No ratings yet',
                    style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vehicleChips() {
    // Vehicle info from driver profile — show generic tags until API provides them
    final labels = [
      'Air-conditioned',
      'Non Smoking',
      '${widget.availableSeats} Seats',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((l) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(l, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        );
      }).toList(),
    );
  }

  Widget _rideDetailsBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: kPrimaryGreen),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Departure',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    widget.currentLocation,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: kErrorRed),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Destination',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    widget.destination,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: kErrorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pickupTimeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.black45),
            SizedBox(width: 6),
            Text('Departure Time:', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.time,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.smoke_free, size: 14, color: Colors.black45),
            SizedBox(width: 6),
            Text('No Smoking', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}