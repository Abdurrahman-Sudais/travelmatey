import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/emergency_sos.dart';
import '../widgets/app_bottom_nav.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;
  final String driverName;
  final double driverRating;
  final String from;
  final String to;
  final String dateTime;
  final int seats;
  final String price;

  const BookingDetailsPage({
    super.key,
    required this.bookingId,
    required this.driverName,
    required this.driverRating,
    required this.from,
    required this.to,
    required this.dateTime,
    required this.seats,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(context),
                    const SizedBox(height: 4),
                    const Text(
                      "Booking Details",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Booking ID: #$bookingId",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _statusBanner(),
                    const SizedBox(height: 16),
                    _driverInfoCard(),
                    const SizedBox(height: 16),
                    _tripDetailsCard(),
                    const SizedBox(height: 16),
                    _paymentDetailsCard(),
                    const SizedBox(height: 16),
                    _actionButtonsRow(),
                    const SizedBox(height: 16),
                    _awaitingDriverNote(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: const AppBottomNavBar(current: AppTab.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
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

  Widget _statusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAmber.withOpacity(0.12),
        border: Border.all(color: kAmber.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: kAmber,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Awaiting Driver Acceptance",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kAmber),
                ),
                SizedBox(height: 2),
                Text(
                  "Your payment is held securely in escrow",
                  style: TextStyle(
                      fontSize: 12.5, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _driverInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Driver Information",
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: kPrimaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "U",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 15, color: kAmber),
                      const SizedBox(width: 4),
                      Text(
                        "$driverRating",
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "(Driver Rating)",
                        style: TextStyle(
                            fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tripDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trip Details",
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: kPrimaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: const Color(0xFFE0E0E0),
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: kPrimaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("From",
                          style: TextStyle(
                              fontSize: 12, color: Colors.black45)),
                      const SizedBox(height: 2),
                      Text(from,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const Text("Ojota Park",
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54)),
                      const SizedBox(height: 18),
                      const Text("To",
                          style: TextStyle(
                              fontSize: 12, color: Colors.black45)),
                      const SizedBox(height: 2),
                      Text(to,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const Text("Ojota Park",
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 17, color: Colors.black45),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Date & Time",
                      style: TextStyle(
                          fontSize: 12, color: Colors.black45)),
                  const SizedBox(height: 2),
                  Text(
                    "Tuesday, June 2, 2026 at 08:00",
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 17, color: Colors.black45),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Seats Booked",
                      style: TextStyle(
                          fontSize: 12, color: Colors.black45)),
                  const SizedBox(height: 2),
                  Text(
                    "$seats seats",
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Details",
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount",
                  style: TextStyle(
                      fontSize: 14, color: Colors.black54)),
              Text(
                price,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryBlue.withOpacity(0.05),
              border: Border.all(color: kPrimaryBlue.withOpacity(0.35)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shield_outlined,
                    size: 18, color: kPrimaryBlue),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment in Escrow",
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryBlue),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Your payment is held securely until the "
                        "driver accepts",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: _outlineButton(
            icon: Icons.edit_outlined,
            label: "Edit Ride",
            sublabel: "Free",
            color: kPrimaryBlue,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _outlineButton(
            icon: Icons.close,
            label: "Cancel Ride",
            sublabel: "5% Fee",
            color: kErrorRed,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _outlineButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                  fontSize: 11.5,
                  color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _awaitingDriverNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kAmber.withOpacity(0.1),
        border: Border.all(color: kAmber.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: kAmber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Awaiting Driver Acceptance",
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: kAmber),
                ),
                SizedBox(height: 4),
                Text(
                  "Communication with the driver (chat & call) will "
                  "be available once the driver accepts your "
                  "booking request. Your payment is safely held in "
                  "escrow.",
                  style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}