import 'package:flutter/material.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class _AppNotification {
  final String id;
  final String title;
  final String body;
  final String category;
  final String time;
  final bool read;

  const _AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.time,
    this.read = false,
  });

  factory _AppNotification.fromJson(Map<String, dynamic> json) {
    return _AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      category: json['category']?.toString() ??
          json['type']?.toString() ??
          'System',
      time: json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          '',
      read: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _filter = "All";
  bool _loading = true;
  bool _showError = false;
  List<_AppNotification> _notifications = [];

  final List<String> _filters = [
    "All",
    "Bookings",
    "Payments",
    "Trips",
    "System",
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _showError = false;
    });
    try {
      final json = await ApiService.instance.get(ApiEndpoints.notificationsMe);
      final list = json['notifications'] as List? ??
          json['data'] as List? ??
          const [];
      setState(() {
        _notifications = list
            .map((item) =>
                _AppNotification.fromJson(item as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _showError = true;
      });
    }
  }

  List<_AppNotification> get _filteredNotifications {
    if (_filter == 'All') return _notifications;
    return _notifications
        .where((n) => n.category.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredNotifications;

    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimaryBlue),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _backButton(),
                        const SizedBox(height: 12),
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_showError) _errorBanner(),
                        if (_showError) const SizedBox(height: 16),
                        _filterRow(),
                        const SizedBox(height: 20),
                        if (items.isEmpty) _emptyState() else ...items.map(_notificationCard),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _notificationCard(_AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notification.read ? Colors.white : kPrimaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.read
              ? Colors.black.withValues(alpha: 0.06)
              : kPrimaryBlue.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        notification.read ? FontWeight.w600 : FontWeight.bold,
                  ),
                ),
              ),
              if (notification.time.isNotEmpty)
                Text(
                  notification.time.length > 16
                      ? notification.time.substring(0, 16)
                      : notification.time,
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
            ],
          ),
          if (notification.body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              notification.body,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ],
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

  Widget _errorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kErrorRed.withValues(alpha: 0.08),
        border: Border.all(color: kErrorRed.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: kErrorRed),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Unable to load notifications. Check your connection.",
                  style: TextStyle(fontSize: 13, color: kErrorRed, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _loadNotifications,
            child: const Text(
              "Try again",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: kErrorRed,
                decoration: TextDecoration.underline,
              ),
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
        children: _filters.map((filter) {
          final bool isActive = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _filter = filter),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? kPrimaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  filter,
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
            child: const Icon(
              Icons.notifications_none,
              size: 36,
              color: Colors.black26,
            ),
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
