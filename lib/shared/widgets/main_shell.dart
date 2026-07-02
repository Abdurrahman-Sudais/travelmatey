import 'package:flutter/material.dart';
import 'package:travelmateeee/core/base/active_role.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/bookings/view/bookings_page.dart';
import 'package:travelmateeee/features/home/view/driver_home_page.dart';
import 'package:travelmateeee/features/home/view/home_page.dart';
import 'package:travelmateeee/features/messages/view/messages_page.dart';
import 'package:travelmateeee/features/profile/view/profile_page.dart';
import 'package:travelmateeee/features/rides/view/my_rides_page.dart';
import 'package:travelmateeee/features/wallet/view/wallet_page.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart';

/// Root shell after sign-in. Owns exactly one [AppBottomNavBar] and switches
/// tab content via [IndexedStack] instead of pushing routes on top of each
/// other.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, theme, child) {
        return ValueListenableBuilder<AppTab>(
          valueListenable: currentTabNotifier,
          builder: (context, tab, _) {
            return ValueListenableBuilder<ActiveRole>(
              valueListenable: activeRoleNotifier,
              builder: (context, role, _) {
                final Widget secondaryTab = role == ActiveRole.driver
                    ? const MyRidesPage()
                    : const BookingsPage();

                return Scaffold(
                  backgroundColor: kBackground,
                  body: IndexedStack(
                    index: tab.index,
                    children: [
                      role == ActiveRole.driver
                          ? const DriverHomePage()
                          : const HomePage(),
                      secondaryTab,
                      const WalletPage(),
                      const MessagesPage(),
                      const ProfilePage(),
                    ],
                  ),
                  bottomNavigationBar: AppBottomNavBar(current: tab),
                );
              },
            );
          },
        );
      },
    );
  }
}
