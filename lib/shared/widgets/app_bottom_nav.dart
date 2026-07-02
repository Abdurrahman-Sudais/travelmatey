import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/home/view/home_page.dart'
    show activeRoleNotifier;
import 'package:travelmateeee/core/base/active_role.dart';
import 'package:travelmateeee/data/repositories/chat_repository.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';

/// Which tab is currently active, shared across rider & driver layouts.
enum AppTab { home, secondary, wallet, chats, profile }

/// Global tab index used by [MainShell]. Call [switchToTab] from anywhere to
/// jump to a primary tab without stacking new routes.
final ValueNotifier<AppTab> currentTabNotifier = ValueNotifier<AppTab>(
  AppTab.home,
);

void switchToTab(AppTab tab) {
  if (currentTabNotifier.value != tab) {
    currentTabNotifier.value = tab;
  }
}

/// Single bottom navigation bar — only rendered once inside [MainShell].
class AppBottomNavBar extends StatefulWidget {
  final AppTab? current;

  const AppBottomNavBar({super.key, this.current});

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  int _chatUnread = 0;
  int _pendingBookings = 0;

  @override
  void initState() {
    super.initState();
    currentTabNotifier.addListener(_onTabChanged);
    _loadBadges();
  }

  @override
  void dispose() {
    currentTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (currentTabNotifier.value == AppTab.chats) {
      _loadBadges();
    }
  }

  Future<void> _loadBadges() async {
    try {
      final chatRepo = Get.find<ChatRepository>();
      final unread = await chatRepo.getTotalUnreadCount();
      int pending = 0;

      final isDriver = activeRoleNotifier.value == ActiveRole.driver;
      if (isDriver) {
        try {
          final json =
              await ApiService.instance.get(ApiEndpoints.bookingsDriverPending);
          final list = json['bookings'] as List? ??
              json['data'] as List? ??
              json['pending'] as List?;
          pending = list?.length ?? 0;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _chatUnread = unread;
          _pendingBookings = pending;
        });
      }
    } catch (_) {}
  }

  void _selectTab(AppTab tab) {
    if (widget.current == tab) return;
    switchToTab(tab);
    if (tab == AppTab.chats || tab == AppTab.secondary) {
      _loadBadges();
    }
  }

  String? _badgeFor(AppTab tab) {
    if (tab == AppTab.chats && _chatUnread > 0) {
      return _chatUnread > 9 ? '9+' : '$_chatUnread';
    }
    if (tab == AppTab.secondary && _pendingBookings > 0) {
      return _pendingBookings > 9 ? '9+' : '$_pendingBookings';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDriver = activeRoleNotifier.value == ActiveRole.driver;

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        boxShadow: [
          BoxShadow(
            color: kNavShadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_filled,
                label: "Home",
                tab: AppTab.home,
                onTap: () => _selectTab(AppTab.home),
              ),
              _navItem(
                icon: isDriver
                    ? Icons.directions_car_outlined
                    : Icons.calendar_month_outlined,
                label: isDriver ? "My Rides" : "Bookings",
                tab: AppTab.secondary,
                badge: _badgeFor(AppTab.secondary),
                onTap: () => _selectTab(AppTab.secondary),
              ),
              _navItem(
                icon: Icons.account_balance_wallet_outlined,
                label: "Wallet",
                tab: AppTab.wallet,
                onTap: () => _selectTab(AppTab.wallet),
              ),
              _navItem(
                icon: Icons.chat_bubble_outline,
                label: "Chats",
                tab: AppTab.chats,
                badge: _badgeFor(AppTab.chats),
                onTap: () => _selectTab(AppTab.chats),
              ),
              _navItem(
                icon: Icons.person_outline,
                label: "Profile",
                tab: AppTab.profile,
                onTap: () => _selectTab(AppTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required AppTab tab,
    String? badge,
    VoidCallback? onTap,
  }) {
    final bool active = widget.current == tab;
    final color = active ? kPrimaryGreen : kTextSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? kPrimaryGreen.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: active ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 22),
                  if (badge != null)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: kErrorRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: active ? 10.5 : 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
