import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../main.dart' show activeRoleNotifier;
import '../pages/search_page.dart';
import '../pages/bookings_page.dart';
import '../pages/profile_page.dart';
import '../pages/my_rides_page.dart';
import '../pages/messages_page.dart';
import '../pages/wallet_page.dart';

/// Which tab is currently active, shared across rider & driver layouts.
enum AppTab { home, secondary, wallet, chats, profile }

/// A single, shared bottom navigation bar used across every page so that
/// tapping any item behaves consistently regardless of which screen the
/// user is currently on.
///
/// - [current] marks the active tab (pass null if the current page isn't
///   one of the five primary tabs, e.g. a detail/chat screen).
/// - The "secondary" tab is "Bookings" for riders and "My Rides" for
///   drivers, decided automatically from [activeRoleNotifier].
class AppBottomNavBar extends StatelessWidget {
  final AppTab? current;

  const AppBottomNavBar({super.key, this.current});

  void _goToRoot(BuildContext context, Widget page) {
    // Pop back to the root (Home) first, then push the requested page,
    // so the bottom nav always behaves the same no matter how deep the
    // user has navigated.
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (page is! _HomeMarker) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDriver = activeRoleNotifier.value == ActiveRole.driver;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                context,
                icon: Icons.home_filled,
                label: "Home",
                tab: AppTab.home,
                onTap: () => _goToRoot(context, const _HomeMarker()),
              ),
              isDriver
                  ? _navItem(
                      context,
                      icon: Icons.directions_car_outlined,
                      label: "My Rides",
                      tab: AppTab.secondary,
                      badge: "3",
                      onTap: () =>
                          _goToRoot(context, const MyRidesPage()),
                    )
                  : _navItem(
                      context,
                      icon: Icons.calendar_month_outlined,
                      label: "Bookings",
                      tab: AppTab.secondary,
                      badge: "2",
                      onTap: () =>
                          _goToRoot(context, const BookingsPage()),
                    ),
              _navItem(
                context,
                icon: Icons.account_balance_wallet_outlined,
                label: "Wallet",
                tab: AppTab.wallet,
                onTap: () => _goToRoot(context, const WalletPage()),
              ),
              _navItem(
                context,
                icon: Icons.chat_bubble_outline,
                label: "Chats",
                tab: AppTab.chats,
                badge: "2",
                onTap: () =>
                    _goToRoot(context, const MessagesPage()),
              ),
              _navItem(
                context,
                icon: Icons.person_outline,
                label: "Profile",
                tab: AppTab.profile,
                onTap: () => _goToRoot(context, const ProfilePage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required AppTab tab,
    String? badge,
    VoidCallback? onTap,
  }) {
    final bool active = current == tab;
    final color = active ? kPrimaryGreen : Colors.black54;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 22),
              if (badge != null)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: kErrorRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(badge,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

/// Internal marker widget used only to signal "go to the Home tab" without
/// constructing a real page (Home is the root route already).
class _HomeMarker extends StatelessWidget {
  const _HomeMarker();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}