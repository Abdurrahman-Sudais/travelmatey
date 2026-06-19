import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart' show switchToTab, AppTab;

class TripCompletedPage extends StatelessWidget {
  final String netEarning;

  const TripCompletedPage({super.key, required this.netEarning});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shield icon
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: kPrimaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: kPrimaryGreen,
                        size: 90,
                      ),
                    ),
                    // Shield with check (stacked)
                    Transform.translate(
                      offset: const Offset(0, -90),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.shield, color: kPrimaryGreen, size: 90),
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 44,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      'Trip Completed',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Thank you for completing this trip safely.\nYour earnings have been added to your wallet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Earnings box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'You Earned',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            netEarning,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // View Wallet
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          switchToTab(AppTab.wallet);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View Wallet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Go to Home
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Go to Home',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
