import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/core/utils/launch_utils.dart';
import 'package:travelmateeee/features/support/view/help_support_page.dart';

/// Simple data holder for an emergency contact row.
class EmergencyContact {
  final String name;
  final String number;
  final bool isServiceContact;

  const EmergencyContact({
    required this.name,
    required this.number,
    this.isServiceContact = false,
  });
}

const List<EmergencyContact> kEmergencyContacts = [
  EmergencyContact(
    name: "Nigeria Emergency Services",
    number: "112",
    isServiceContact: true,
  ),
  EmergencyContact(name: "Police", number: "199", isServiceContact: true),
];

/// Global toggle. Flip to true on pages that should NOT show the SOS button.
final ValueNotifier<bool> hideEmergencySosButton = ValueNotifier<bool>(false);

/// Wrap an excluded page's widget with this to auto-hide the SOS button.
class HideEmergencySos extends StatefulWidget {
  final Widget child;
  const HideEmergencySos({super.key, required this.child});

  @override
  State<HideEmergencySos> createState() => _HideEmergencySosState();
}

class _HideEmergencySosState extends State<HideEmergencySos> {
  @override
  void initState() {
    super.initState();
    hideEmergencySosButton.value = true;
  }

  @override
  void dispose() {
    hideEmergencySosButton.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Wrap every page Scaffold with this.
class SosScaffold extends StatelessWidget {
  final Widget child;
  const SosScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<bool>(
          valueListenable: hideEmergencySosButton,
          builder: (context, hide, _) {
            if (hide) return const SizedBox.shrink();
            return const Positioned(
              right: 16,
              bottom: 110,
              child: EmergencySosButton(),
            );
          },
        ),
      ],
    );
  }
}

/// Pulsing red SOS button.
class EmergencySosButton extends StatefulWidget {
  const EmergencySosButton({super.key});

  @override
  State<EmergencySosButton> createState() => _EmergencySosButtonState();
}

class _EmergencySosButtonState extends State<EmergencySosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSosSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmergencySosSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openSosSheet,
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: kErrorRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55FF4B4B),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Emergency SOS bottom sheet — supports multi-select contacts.
class EmergencySosSheet extends StatefulWidget {
  const EmergencySosSheet({super.key});

  @override
  State<EmergencySosSheet> createState() => _EmergencySosSheetState();
}

class _EmergencySosSheetState extends State<EmergencySosSheet> {
  /// Multi-select: store all selected contact numbers.
  final Set<String> _selectedNumbers = {};

  bool get canActivate => _selectedNumbers.isNotEmpty;

  int get _selectedCount => _selectedNumbers.length;

  void _toggleContact(EmergencyContact contact) {
    setState(() {
      if (_selectedNumbers.contains(contact.number)) {
        _selectedNumbers.remove(contact.number);
      } else {
        _selectedNumbers.add(contact.number);
      }
    });
  }

  void _activateEmergency() {
    // Close this sheet, then show the countdown screen.
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => EmergencyCountdownSheet(selectedCount: _selectedCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tripDetailsCard(),
                    const SizedBox(height: 20),
                    const Text(
                      "Select contacts to alert",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...kEmergencyContacts.map(_contactRow),
                    const SizedBox(height: 6),
                    _liveLocationCard(),
                    const SizedBox(height: 16),
                    _actionButtonsRow(),
                    const SizedBox(height: 16),
                    _activateButton(),
                    const SizedBox(height: 8),
                    if (!canActivate)
                      const Center(
                        child: Text(
                          "Select at least one contact to activate emergency",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: kErrorRed),
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

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kErrorRed, Color(0xFFFF7676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency SOS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Safety is our priority",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kAmber.withValues(alpha: 0.12),
        border: Border.all(color: kAmber.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, size: 16, color: kAmber),
              SizedBox(width: 6),
              Text(
                "Current Trip Details",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Driver: Adebayo Johnson",
            style: TextStyle(fontSize: 12.5),
          ),
          const SizedBox(height: 2),
          const Text("Route: Abuja → Lagos", style: TextStyle(fontSize: 12.5)),
          const SizedBox(height: 2),
          const Text(
            "Vehicle: Toyota Camry (Grey) - ABC-123-XY",
            style: TextStyle(fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
              SizedBox(width: 4),
              Text(
                "Approaching Lokoja Junction",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactRow(EmergencyContact contact) {
    final bool isSelected = _selectedNumbers.contains(contact.number);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? kErrorRed : Colors.black.withValues(alpha: 0.06),
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          // Tap entire left area to toggle selection
          InkWell(
            onTap: () => _toggleContact(contact),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: contact.isServiceContact
                    ? kErrorRed.withValues(alpha: 0.12)
                    : kPrimaryBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                contact.isServiceContact
                    ? Icons.call
                    : Icons.people_alt_outlined,
                size: 16,
                color: contact.isServiceContact ? kErrorRed : kPrimaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => _toggleContact(contact),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    contact.number,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Checkbox circle — tap to toggle
          InkWell(
            onTap: () => _toggleContact(contact),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.redAccent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.redAccent : Colors.black26,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          // Direct call button
          InkWell(
            onTap: () => launchPhoneCall(contact.number, context: context),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(
                color: kPrimaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryBlue.withValues(alpha: 0.05),
        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.location_on_outlined, color: kPrimaryBlue, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Live Location Sharing",
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  "Selected contacts will receive real-time location updates and trip details",
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: _secondaryButton(
            label: "Call Police",
            icon: Icons.call,
            color: kPrimaryBlue,
            onTap: () => launchPhoneCall('199', context: context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _secondaryButton(
            label: "Contact Support",
            icon: Icons.chat_bubble_outline,
            color: kPrimaryGreen,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _secondaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activateButton() {
    return InkWell(
      onTap: canActivate ? _activateEmergency : null,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: canActivate ? kErrorRed : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: canActivate ? Colors.white : Colors.black38,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "Activate Emergency",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: canActivate ? Colors.white : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Countdown activation sheet shown after pressing "Activate Emergency".
class EmergencyCountdownSheet extends StatefulWidget {
  final int selectedCount;
  const EmergencyCountdownSheet({super.key, required this.selectedCount});

  @override
  State<EmergencyCountdownSheet> createState() =>
      _EmergencyCountdownSheetState();
}

class _EmergencyCountdownSheetState extends State<EmergencyCountdownSheet>
    with SingleTickerProviderStateMixin {
  int _seconds = 5;
  Timer? _timer;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the countdown circle — same fades-in-and-out as SOS button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseOpacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _seconds--);
      if (_seconds <= 0) {
        t.cancel();
        launchPhoneCall('112');
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _cancelEmergency() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing countdown circle
                    AnimatedBuilder(
                      animation: _pulseOpacity,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            Opacity(
                              opacity: _pulseOpacity.value * 0.3,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kErrorRed.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            // Inner circle with number
                            Opacity(
                              opacity: _pulseOpacity.value,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kErrorRed,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "$_seconds",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      "Emergency Activating...",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Alerting ${widget.selectedCount} contact${widget.selectedCount == 1 ? '' : 's'} with your location and trip details",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kAmber.withValues(alpha: 0.1),
                        border: Border.all(color: kAmber.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "📍 Sharing live location",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "📱 Sending SMS alerts",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "🚨 Notifying Travelmate support",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    InkWell(
                      onTap: _cancelEmergency,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Cancel Emergency",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
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

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kErrorRed, Color(0xFFFF7676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency SOS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Safety is our priority",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _cancelEmergency,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
