import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.chevron_left, size: 22),
                          Text('Back', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('About Travelmate',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    // Hero card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.directions_car,
                                    color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 12),
                              const Text('About Travelmate',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Travelmate is a smart carpooling platform designed to connect drivers and riders travelling in the same direction, making transportation more affordable, convenient, and secure across Nigeria.',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.6),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Owned and operated by COTECH INVESTMENT LIMITED (RC No. 101039). Travelmate leverages modern technology to simplify shared mobility while promoting safety, transparency, and trust within our community.',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Our Mission
                    _card(
                      icon: Icons.track_changes_outlined,
                      iconColor: kPrimaryGreen,
                      title: 'Our Mission',
                      child: const Text(
                        'To make everyday travel cheaper, faster, and more efficient by enabling people to share rides, reduce transport costs, and build a trusted community of responsible drivers and riders.',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // What We Do
                    _card(
                      icon: Icons.grid_view_outlined,
                      iconColor: kPrimaryBlue,
                      title: 'What We Do',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Travelmate is a digital marketplace, not a transport company. We provide the technology that allows:',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.5),
                          ),
                          const SizedBox(height: 14),
                          _featureItem(Icons.add_road,
                              'Drivers to post their available trips'),
                          _featureItem(Icons.search,
                              'Riders to find, request, and book seats'),
                          _featureItem(Icons.chat_bubble_outline,
                              'Cashless in-app communication between users'),
                          _featureItem(Icons.account_balance_wallet_outlined,
                              'Secure in-app wallet and escrow system'),
                          _featureItem(Icons.location_on_outlined,
                              'Real-time GPS tracking for safety and transparency'),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'By using Travelmate, users can travel conveniently while contributing to reduced congestion, lower fuel costs, and a more sustainable transport system.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // How Travelmate Works
                    _card(
                      icon: Icons.help_outline,
                      iconColor: kAmber,
                      title: 'How Travelmate Works',
                      child: Column(
                        children: [
                          _howStep(
                            number: '1',
                            color: kPrimaryBlue,
                            title: 'Post or Find a Trip',
                            body:
                                'Drivers list their routes, time, and available seats. Riders search for trips that match their journey.',
                          ),
                          const SizedBox(height: 12),
                          _howStep(
                            number: '2',
                            color: kPrimaryGreen,
                            title: 'Book & Pay Securely',
                            body:
                                'Riders make part or full payment through the Travelmate Wallet. Funds are held safely in escrow.',
                          ),
                          const SizedBox(height: 12),
                          _howStep(
                            number: '3',
                            color: kAmber,
                            title: 'Start the Trip',
                            body:
                                'When the rider confirms Trip In Progress, the system releases the payment to the driver.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54))),
        ],
      ),
    );
  }

  Widget _howStep({
    required String number,
    required Color color,
    required String title,
    required String body,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(body,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}