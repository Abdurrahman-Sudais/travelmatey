import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/data/models/ride_model.dart';
import 'package:travelmateeee/data/repositories/ride_repository.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/features/bookings/view/ride_listing_details_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String from;
  final String to;
  final String date;
  final int passengers;

  const SearchResultsPage({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool _filtersOpen = true;
  String _sortBy = "Earliest Departure";
  RangeValues _priceRange = const RangeValues(0, 50000);
  String _minRating = "Any";
  bool _verifiedOnly = true;

  bool _isLoading = true;
  List<RideModel> _rides = [];
  final RideRepository _repo = createRideRepository();

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    setState(() => _isLoading = true);
    try {
      _rides = await _repo.searchRides(
        from: widget.from,
        to: widget.to,
        date: widget.date,
        seats: widget.passengers,
      );
    } catch (e) {
      Get.snackbar(
        'Search Failed',
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

  List<RideModel> get _filtered {
    var list = _rides.where((l) {
      final price = l.pricePerSeat;
      if (price < _priceRange.start || price > _priceRange.end) return false;
      // Verification logic could go here if we had l.driver.isVerified
      if (_minRating != "Any") {
        final min = double.parse(_minRating.replaceAll("+", ""));
        if ((l.driver?.rating ?? 0.0) < min) return false;
      }
      return true;
    }).toList();
    
    if (_sortBy == "Lowest Price") {
      list.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
    } else if (_sortBy == "Highest Rating") {
      list.sort((a, b) => (b.driver?.rating ?? 0.0).compareTo(a.driver?.rating ?? 0.0));
    } else {
      // Earliest departure by default
      list.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }

    return list;
  }

  void _clearFilters() {
    setState(() {
      _sortBy = "Earliest Departure";
      _priceRange = const RangeValues(0, 50000);
      _minRating = "Any";
      _verifiedOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(),
                    const SizedBox(height: 14),
                    Text(
                      "${widget.from} → ${widget.to}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.date} • ${widget.passengers} passenger"
                      "${widget.passengers == 1 ? '' : 's'}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _filtersToggle(),
                    if (_filtersOpen) ...[
                      const SizedBox(height: 14),
                      _filtersPanel(),
                    ],
                    const SizedBox(height: 16),
                    _availableRidesBadge(results.length),
                    const SizedBox(height: 16),
                    if (results.isEmpty)
                      _noResults()
                    else
                      ...results.map(_rideCard),
                  ],
                ),
              )),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chevron_left, size: 22, color: Colors.black87),
              Text(
                "New Search",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 24,
              color: Colors.black87,
            ),
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

  Widget _filtersToggle() {
    return InkWell(
      onTap: () => setState(() => _filtersOpen = !_filtersOpen),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune, size: 16, color: kPrimaryBlue),
          const SizedBox(width: 6),
          const Text(
            "Filters",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
            ),
          ),
          Icon(
            _filtersOpen ? Icons.expand_less : Icons.expand_more,
            size: 18,
            color: kPrimaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _filtersPanel() {
    final ratingOptions = ["Any", "2+", "3+", "4+", "4.5+"];
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
          const Text(
            "Sort by",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _sortBy,
                items:
                    const [
                          "Earliest Departure",
                          "Lowest Price",
                          "Highest Rating",
                        ]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (v) => setState(() => _sortBy = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Price Range",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 50000,
            divisions: 50,
            activeColor: Colors.black87,
            inactiveColor: Colors.black12,
            labels: RangeLabels(
              "₦${_priceRange.start.round()}",
              "₦${_priceRange.end.round()}",
            ),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₦${_priceRange.start.round()}",
                style: const TextStyle(fontSize: 11.5, color: Colors.black54),
              ),
              Text(
                "₦${_priceRange.end.round()}",
                style: const TextStyle(fontSize: 11.5, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Minimum Driver Rating:",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ratingOptions.map((r) {
              final isActive = _minRating == r;
              return InkWell(
                onTap: () => setState(() => _minRating = r),
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.black87 : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Checkbox(
                value: _verifiedOnly,
                activeColor: kPrimaryBlue,
                onChanged: (v) => setState(() => _verifiedOnly = v ?? false),
              ),
              const Text(
                "Verified Drivers Only",
                style: TextStyle(fontSize: 13),
              ),
              const Spacer(),
              InkWell(
                onTap: _clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Text(
                    "Clear All Filters",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _availableRidesBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_car_filled,
            size: 16,
            color: kPrimaryGreen,
          ),
          const SizedBox(width: 8),
          Text(
            "$count\nAvailable Rides",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kPrimaryGreen,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.filter_alt_off_outlined,
            size: 34,
            color: Colors.black38,
          ),
          const SizedBox(height: 14),
          const Text(
            "No rides match your filters",
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try adjusting your filter criteria or post your own ride",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Post The Search",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rideCard(RideModel l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black38),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.driver?.name ?? "Unknown Driver",
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                        4,
                        (i) => const Icon(Icons.star, size: 13, color: kAmber),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₦${l.pricePerSeat.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
                    ),
                  ),
                  Text(
                    "${l.availableSeats} Seats available",
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: kPrimaryGreen),
              const SizedBox(width: 6),
              Text(l.from, style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 13, color: kErrorRed),
              const SizedBox(width: 6),
              Text(l.to, style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: Colors.black45,
              ),
              const SizedBox(width: 6),
              Text(
                l.departureTime,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RideListingDetailsPage(
                        rideId: l.id,
                        driverName: l.driver?.name ?? 'Unknown Driver',
                        currentLocation: l.from,
                        destination: l.to,
                        price: '₦${l.pricePerSeat.toStringAsFixed(0)}',
                        date: l.departureTime,
                        time: l.departureTime,
                        driverRating: l.driver?.rating ?? 0.0,
                        availableSeats: l.availableSeats,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "View listing",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
