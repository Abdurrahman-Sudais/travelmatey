import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _filter = "All";
  bool _showError = true;

  final List<String> _filters = [
    "All",
    "Bookings",
    "Payments",
    "Trips",
    "System",
  ];

  void _retry() {
    setState(() {
      // TODO: re-fetch notifications from server
      _showError = false;
    });
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
                    _backButton(),
                    const SizedBox(height: 12),
                    const Text(
                      "Notifications",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (_showError) _errorBanner(),
                    if (_showError) const SizedBox(height: 16),
                    _filterRow(),
                    const SizedBox(height: 60),
                    _emptyState(),
                  ],
                ),
              )),
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
          Text("Back",
              style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kErrorRed.withOpacity(0.08),
        border: Border.all(color: kErrorRed.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.warning_amber_rounded,
                  size: 18, color: kErrorRed),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Network error: Unable to reach server. Please "
                  "check your connection and try again.",
                  style: TextStyle(
                      fontSize: 13, color: kErrorRed, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _retry,
            child: const Text(
              "Try again",
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: kErrorRed,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final bool isActive = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _filter = f),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? kPrimaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 13.5,
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
    return Center(
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none,
                size: 36, color: Colors.black26),
          ),
          const SizedBox(height: 16),
          const Text(
            "No notifications",
            style: TextStyle(fontSize: 17, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}