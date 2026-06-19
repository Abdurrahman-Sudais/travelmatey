import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class _NotifItem {
  final String title;
  final String subtitle;
  final bool important;
  bool value;

  _NotifItem({
    required this.title,
    required this.subtitle,
    this.important = false,
    this.value = true,
  });
}

class _NotifSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<_NotifItem> items;
  bool expanded = true;

  _NotifSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.items,
  });
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends State<NotificationSettingsPage> {
  late final List<_NotifSection> sections = [
    _NotifSection(
      title: "Notification Channels",
      subtitle: "Choose how you want to receive notifications",
      icon: Icons.notifications_outlined,
      iconColor: kPrimaryBlue,
      items: [
        _NotifItem(
            title: "Push Notifications",
            subtitle: "Receive notifications on your device",
            important: true),
        _NotifItem(
            title: "Email Notifications",
            subtitle: "Receive updates via email"),
        _NotifItem(
            title: "SMS Notifications",
            subtitle: "Get important alerts via SMS",
            value: false),
      ],
    ),
    _NotifSection(
      title: "Trip Notifications",
      subtitle: "Stay updated about your trips",
      icon: Icons.map_outlined,
      iconColor: kPrimaryGreen,
      items: [
        _NotifItem(
            title: "Trip Reminders",
            subtitle: "Get reminded before your trip starts",
            important: true),
        _NotifItem(
            title: "Trip Updates",
            subtitle: "Changes to your scheduled trips",
            important: true),
        _NotifItem(
            title: "Driver Arrival",
            subtitle: "When driver is arriving at pickup point",
            important: true),
        _NotifItem(
            title: "Trip Started",
            subtitle: "Confirmation when trip begins"),
        _NotifItem(
            title: "Trip Completed",
            subtitle: "Summary when trip ends"),
      ],
    ),
    _NotifSection(
      title: "Booking Notifications",
      subtitle: "Manage booking-related alerts",
      icon: Icons.assignment_outlined,
      iconColor: kAmber,
      items: [
        _NotifItem(
            title: "Booking Requests",
            subtitle: "When riders request to book your ride",
            important: true),
        _NotifItem(
            title: "Booking Confirmed",
            subtitle: "When your booking is confirmed",
            important: true),
        _NotifItem(
            title: "Booking Cancelled",
            subtitle: "When a booking is cancelled",
            important: true),
        _NotifItem(
            title: "Rider No-Show",
            subtitle: "When a rider doesn't show up"),
      ],
    ),
    _NotifSection(
      title: "Payment Notifications",
      subtitle: "Track your financial transactions",
      icon: Icons.credit_card_outlined,
      iconColor: kPrimaryBlue,
      items: [
        _NotifItem(
            title: "Payment Received",
            subtitle: "When you receive payment",
            important: true),
        _NotifItem(
            title: "Payment Refunded",
            subtitle: "When a refund is processed",
            important: true),
        _NotifItem(
            title: "Wallet Updates",
            subtitle: "Changes to your wallet balance"),
        _NotifItem(
            title: "Withdrawal Status",
            subtitle: "Updates on withdrawal requests",
            important: true),
      ],
    ),
    _NotifSection(
      title: "Chat & Communication",
      subtitle: "Messages and call notifications",
      icon: Icons.chat_bubble_outline,
      iconColor: kPrimaryGreen,
      items: [
        _NotifItem(
            title: "New Messages",
            subtitle: "When you receive a new message",
            important: true),
        _NotifItem(
            title: "Missed Calls", subtitle: "When you miss a call"),
      ],
    ),
  ];

  void _enableAll() {
    setState(() {
      for (final s in sections) {
        for (final i in s.items) {
          i.value = true;
        }
      }
    });
  }

  void _disableAll() {
    setState(() {
      for (final s in sections) {
        for (final i in s.items) {
          i.value = false;
        }
      }
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
                      "Notification Settings",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Customize your notification preferences",
                      style:
                          TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _enableDisableRow(),
                    const SizedBox(height: 16),
                    ...sections.map(_sectionCard),
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

  Widget _enableDisableRow() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _enableAll,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kPrimaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Enable All",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _disableAll,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kErrorRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Disable All",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kErrorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(_NotifSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => section.expanded = !section.expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: section.iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(section.icon,
                        color: section.iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(section.subtitle,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.black54)),
                      ],
                    ),
                  ),
                  Icon(
                    section.expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            crossFadeState: section.expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(
                children: List.generate(section.items.length, (i) {
                  final item = section.items[i];
                  return Column(
                    children: [
                      if (i > 0)
                        const Divider(height: 1, color: Color(0xFFF2F2F2)),
                      _notifRow(item),
                    ],
                  );
                }),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _notifRow(_NotifItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600)),
                    if (item.important) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: kErrorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "IMPORTANT",
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: kErrorRed),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(item.subtitle,
                    style: const TextStyle(
                        fontSize: 11.5, color: Colors.black54)),
              ],
            ),
          ),
          Switch(
            value: item.value,
            activeThumbColor: kPrimaryGreen,
            onChanged: (v) => setState(() => item.value = v),
          ),
        ],
      ),
    );
  }
}