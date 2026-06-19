import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/features/bookings/view/request_sent_page.dart';

class RideListingDetailsPage extends StatelessWidget {
  final String driverName;
  final String currentLocation;
  final String destination;
  final String price;
  final String date;
  final String time;

  const RideListingDetailsPage({
    super.key,
    required this.driverName,
    required this.currentLocation,
    required this.destination,
    required this.price,
    required this.date,
    required this.time,
  });

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
                      "Bio",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: "Driving back and forth Lagos and Abuja "
                                "for over three years. ",
                          ),
                          TextSpan(
                            text: "Read More",
                            style: const TextStyle(
                              color: kPrimaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _vehicleChips(),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Ride Details",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "($date)",
                          style: const TextStyle(fontSize: 12.5, color: Colors.black45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _rideDetailsBox(),
                    const SizedBox(height: 14),
                    _pickupTimeSmokingRow(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        const Text("Price: ",
                            style: TextStyle(fontSize: 14, color: Colors.black54)),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "Driver reviews",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _reviewRow("Devon Lane", 5),
                    const SizedBox(height: 10),
                    _reviewRow("Courtney Henry", 4),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RequestSentPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Book a ride",
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
              )),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chevron_left, size: 22, color: Colors.black87),
              Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
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
                driverName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Joined since December 2023",
                style: TextStyle(fontSize: 12, color: kPrimaryBlue),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(
                    4,
                    (i) => const Icon(Icons.star, size: 14, color: kAmber),
                  ),
                  const Icon(Icons.star_border, size: 14, color: kAmber),
                  const SizedBox(width: 4),
                  const Text(
                    "4.9 (531 reviews)",
                    style: TextStyle(fontSize: 11.5, color: Colors.black54),
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
    final labels = [
      "Toyota",
      "Airconditioned",
      "Camry",
      "Non Smoking",
      "Green",
      "3 Seats",
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
        color: kPrimaryBlue.withOpacity(0.06),
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
                    "Current location",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    "$currentLocation, Nigeria",
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
                    "Destination",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    "$destination, Nigeria",
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

  Widget _pickupTimeSmokingRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.location_pin, size: 14, color: Colors.black45),
            SizedBox(width: 4),
            Text("Pickup", style: TextStyle(fontSize: 11.5, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "$currentLocation, AYM Shafa Filling Station",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.access_time, size: 14, color: Colors.black45),
            const SizedBox(width: 6),
            const Text("Time: ", style: TextStyle(fontSize: 12.5, color: Colors.black54)),
            Text(time, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            const SizedBox(width: 18),
            const Icon(Icons.smoke_free, size: 14, color: Colors.black45),
            const SizedBox(width: 6),
            const Text("No Smoking", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _reviewRow(String name, int stars) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE5E5E5),
            child: Icon(Icons.person, size: 16, color: Colors.black38),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 12,
                      color: i < stars ? kAmber : Colors.black12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "View",
            style: TextStyle(fontSize: 12.5, color: kPrimaryBlue, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}