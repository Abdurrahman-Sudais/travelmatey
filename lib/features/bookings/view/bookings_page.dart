import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/data/models/booking_model.dart';
import 'package:travelmateeee/data/repositories/booking_repository.dart';
import 'package:travelmateeee/core/base/active_role.dart';
import 'package:travelmateeee/features/home/view/home_page.dart' show activeRoleNotifier;
import 'package:travelmateeee/shared/widgets/conditional_back_button.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/features/bookings/view/booking_details_page.dart';
import 'package:travelmateeee/features/bookings/view/search_ride_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String _filter = "All";
  bool _isLoading = true;
  List<BookingModel> _requests = [];
  final BookingRepository _repo = createBookingRepository();

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      var user = AuthService.instance.currentUser;
      user ??= await AuthService.instance.getMe();

      if (activeRoleNotifier.value == ActiveRole.driver) {
        _requests = await _repo.getDriverPendingBookings();
      } else {
        _requests = await _repo.getUserBookings(user.id);
      }
    } catch (e) {
      Get.snackbar(
        'Error fetching bookings',
        e.toString(),
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<BookingModel> get _filtered {
    if (_filter == "All") return _requests;
    return _requests.where((r) {
      if (_filter == "Pending") return r.status == "pending";
      if (_filter == "Accepted") return r.status == "accepted";
      if (_filter == "Paid") return r.paymentStatus == "paid";
      if (_filter == "Completed") return r.status == "completed";
      return true;
    }).toList();
  }

  int _countFor(String filter) {
    if (filter == "All") return _requests.length;
    return _requests.where((r) {
      if (filter == "Pending") return r.status == "pending";
      if (filter == "Accepted") return r.status == "accepted";
      if (filter == "Paid") return r.paymentStatus == "paid";
      if (filter == "Completed") return r.status == "completed";
      return true;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimaryBlue),
                )
              : RefreshIndicator(
                  onRefresh: _fetchBookings,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const ConditionalBackButton(),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SearchRidePage(),
                                ),
                              ).then((_) => _fetchBookings());
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add, size: 16, color: kPrimaryBlue),
                                SizedBox(width: 4),
                                Text(
                                  "New Search",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
        ),
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
        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.35)),
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

  Widget _bookingCard(BookingModel r) {
    final driverName = r.driver?.name ?? "Unknown Driver";
    final driverRating = r.driver?.rating ?? 0.0;
    final from = r.ride?.from ?? "Unknown";
    final to = r.ride?.to ?? "Unknown";
    final dateTime = r.ride?.departureTime ?? r.createdAt;
    final seats = r.seatsBooked;
    final priceStr = "₦${r.totalPrice.toStringAsFixed(0)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star, size: 14, color: kAmber),
                    const SizedBox(width: 2),
                    Text(
                      "$driverRating",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(r.status, r.paymentStatus),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                from,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 16, color: Colors.black38),
              const SizedBox(width: 6),
              Text(
                to,
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
                dateTime,
                style: const TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
              const Spacer(),
              const Icon(Icons.people_outline, size: 15, color: Colors.black45),
              const SizedBox(width: 6),
              Text(
                "$seats seats",
                style: const TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                priceStr,
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
                        driverName: driverName,
                        driverRating: driverRating,
                        from: from,
                        to: to,
                        dateTime: dateTime,
                        seats: seats,
                        price: priceStr,
                      ),
                    ),
                  ).then((_) => _fetchBookings());
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

  Widget _statusBadge(String status, String paymentStatus) {
    String label = "Pending";
    Color color = kAmber;
    
    if (status == 'completed') {
      label = "Completed";
      color = kPrimaryGreen;
    } else if (paymentStatus == 'paid') {
      label = "Paid";
      color = kPrimaryGreen;
    } else if (status == 'accepted') {
      label = "Accepted";
      color = kPrimaryBlue;
    } else if (status == 'cancelled') {
      label = "Cancelled";
      color = kErrorRed;
    }

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