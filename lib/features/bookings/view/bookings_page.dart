import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart';
import 'package:travelmateeee/features/bookings/view/booking_details_page.dart';

enum _BookingStatus { pending, accepted, paid, completed }

class _BookingRequest {
  final String id;
  final String driverName;
  final double driverRating;
  final String from;
  final String to;
  final String dateTime;
  final int seats;
  final String price;
  final _BookingStatus status;

  const _BookingRequest({
    required this.id,
    required this.driverName,
    required this.driverRating,
    required this.from,
    required this.to,
    required this.dateTime,
    required this.seats,
    required this.price,
    required this.status,
  });
}

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String _filter = "All";

  final List<_BookingRequest> requests = const [
    _BookingRequest(
      id: "booking_1",
      driverName: "Unknown Driver",
      driverRating: 4.8,
      from: "Lagos",
      to: "Ibadan",
      dateTime: "Jun 2, 2026 at 08:00",
      seats: 2,
      price: "₦10,000",
      status: _BookingStatus.pending,
    ),
  ];

  List<_BookingRequest> get _filtered {
    switch (_filter) {
      case "Pending":
        return requests
            .where((r) => r.status == _BookingStatus.pending)
            .toList();
      case "Accepted":
        return requests
            .where((r) => r.status == _BookingStatus.accepted)
            .toList();
      case "Paid":
        return requests.where((r) => r.status == _BookingStatus.paid).toList();
      case "Completed":
        return requests
            .where((r) => r.status == _BookingStatus.completed)
            .toList();
      default:
        return requests;
    }
  }

  int _countFor(String filter) {
    switch (filter) {
      case "Pending":
        return requests.where((r) => r.status == _BookingStatus.pending).length;
      case "Accepted":
        return requests
            .where((r) => r.status == _BookingStatus.accepted)
            .length;
      case "Paid":
        return requests.where((r) => r.status == _BookingStatus.paid).length;
      case "Completed":
        return requests
            .where((r) => r.status == _BookingStatus.completed)
            .length;
      default:
        return requests.length;
    }
  }

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
                    _backButton(),
                    const SizedBox(height: 12),
                    const Text(
                      "My Booking Requests",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Active booking requests sent to drivers",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _infoBanner(),
                    const SizedBox(height: 16),
                    _filterRow(),
                    const SizedBox(height: 16),
                    if (_filtered.isEmpty)
                      _emptyState()
                    else
                      ..._filtered.map(_bookingCard),
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

  Widget _infoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryBlue.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, size: 18, color: kPrimaryBlue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "You can only have a maximum of 2 active booking "
              "requests at a time. Complete or cancel existing "
              "requests to make new ones.",
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow() {
    final filters = ["All", "Pending", "Accepted", "Paid", "Completed"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final bool isActive = _filter == f;
          final count = _countFor(f);
          final label = f == "All" || f == "Pending" ? "$f ($count)" : f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _filter = f),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? kPrimaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: const Text(
        "No booking requests here.",
        style: TextStyle(color: Colors.black38),
      ),
    );
  }

  Widget _bookingCard(_BookingRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      r.driverName,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star, size: 14, color: kAmber),
                    const SizedBox(width: 2),
                    Text(
                      "${r.driverRating}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(r.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                r.from,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 16, color: Colors.black38),
              const SizedBox(width: 6),
              Text(
                r.to,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Colors.black45,
              ),
              const SizedBox(width: 6),
              Text(
                r.dateTime,
                style: const TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
              const Spacer(),
              const Icon(Icons.people_outline, size: 15, color: Colors.black45),
              const SizedBox(width: 6),
              Text(
                "${r.seats} seats",
                style: const TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r.price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailsPage(
                        bookingId: r.id,
                        driverName: r.driverName,
                        driverRating: r.driverRating,
                        from: r.from,
                        to: r.to,
                        dateTime: r.dateTime,
                        seats: r.seats,
                        price: r.price,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "View Details",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryBlue,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 16, color: kPrimaryBlue),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(_BookingStatus status) {
    final label = switch (status) {
      _BookingStatus.pending => "Awaiting Driver",
      _BookingStatus.accepted => "Accepted",
      _BookingStatus.paid => "Paid",
      _BookingStatus.completed => "Completed",
    };
    final color = switch (status) {
      _BookingStatus.pending => kAmber,
      _BookingStatus.accepted => kPrimaryBlue,
      _BookingStatus.paid => kPrimaryGreen,
      _BookingStatus.completed => kPrimaryGreen,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
