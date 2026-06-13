import 'package:flutter/material.dart';

// Local color tokens (kept private/prefixed so this file can be dropped
// into a project alongside main.dart / search_page.dart without
// clashing with their top-level color constants).
const Color _kBackground = Color(0xFFEBF3FB);
const Color _kPrimaryGreen = Color(0xFF008000);
const Color _kPrimaryBlue = Color(0xFF0b6cb9);
const Color _kErrorRed = Color(0xFFFF4B4B);
const Color _kAmber = Color(0xFFF59E0B);

/// Simple data holder for an emergency contact row.
class EmergencyContact {
  final String name;
  final String number;
  final bool isServiceContact; // true -> red phone icon, false -> blue people icon

  const EmergencyContact({
    required this.name,
    required this.number,
    this.isServiceContact = false,
  });
}

const List<EmergencyContact> _kEmergencyContacts = [
  EmergencyContact(name: "Nigeria Emergency Services", number: "112", isServiceContact: true),
  EmergencyContact(name: "Police", number: "199", isServiceContact: true),
  EmergencyContact(name: "Mom", number: "+234 803 123 4567"),
  EmergencyContact(name: "Dad", number: "+234 805 234 5678"),
  EmergencyContact(name: "Best Friend", number: "+234 807 345 6789"),
];

/// Global toggle. Defaults to "visible everywhere". Pages that should NOT
/// show the SOS button (onboarding, sign in/up, KYC, etc.) flip this to
/// true while they're on screen — wrap their build output with
/// [HideEmergencySos] to do that automatically.
final ValueNotifier<bool> hideEmergencySosButton = ValueNotifier<bool>(false);

/// Wrap an "excluded" page's returned widget with this. While that page is
/// mounted, the global SOS button is hidden; it reappears automatically
/// once the page is disposed (i.e. the user navigates away).
///
/// Usage (onboarding, sign in, sign up, KYC screens, etc.):
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return HideEmergencySos(
///     child: Scaffold(...),
///   );
/// }
/// ```
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

/// Drop this once into `MaterialApp.builder`. It overlays the pulsing SOS
/// button on top of every screen in the app, unless
/// [hideEmergencySosButton] is currently true.
class GlobalEmergencySosOverlay extends StatelessWidget {
  const GlobalEmergencySosOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hideEmergencySosButton,
      builder: (context, hide, _) {
        if (hide) return const SizedBox.shrink();
        return const Positioned(
          right: 16,
          bottom: 110,
          child: EmergencySosButton(),
        );
      },
    );
  }
}


/// ~55% and 100% opacity in a loop, never disappearing completely.
/// Tapping it opens the Emergency SOS bottom sheet.
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

    _opacity = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: _kErrorRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

/// Emergency SOS bottom sheet (slides up from the bottom).
/// Matches the two screenshots: red header with trip details, contact
/// list with radio + call buttons, live location card, action buttons,
/// and the "Activate Emergency" CTA.
class EmergencySosSheet extends StatefulWidget {
  const EmergencySosSheet({super.key});

  @override
  State<EmergencySosSheet> createState() => _EmergencySosSheetState();
}

class _EmergencySosSheetState extends State<EmergencySosSheet> {
  String? selectedContactNumber;

  bool get canActivate => selectedContactNumber != null;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: const BoxDecoration(
          color: _kBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ..._kEmergencyContacts.map(_contactRow),
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
                          style: TextStyle(fontSize: 12, color: _kErrorRed),
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

  // Red gradient header with shield icon, title/subtitle, close button.
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kErrorRed, Color(0xFFFF7676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
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
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Amber "Current Trip Details" card.
  Widget _tripDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kAmber.withOpacity(0.12),
        border: Border.all(color: _kAmber.withOpacity(0.45)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: _kAmber, size: 18),
              SizedBox(width: 8),
              Text(
                "Current Trip Details",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Driver: Adebayo Johnson", style: TextStyle(fontSize: 12.5)),
          const SizedBox(height: 2),
          const Text("Route: Abuja → Lagos", style: TextStyle(fontSize: 12.5)),
          const SizedBox(height: 2),
          const Text("Vehicle: Toyota Camry (Grey) - ABC-123-XY", style: TextStyle(fontSize: 12.5)),
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

  // Single contact row: leading icon, name + number, radio, green call button.
  Widget _contactRow(EmergencyContact contact) {
    final bool isSelected = selectedContactNumber == contact.number;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _kPrimaryGreen : Colors.black.withOpacity(0.06),
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: contact.isServiceContact
                  ? _kErrorRed.withOpacity(0.12)
                  : _kPrimaryBlue.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              contact.isServiceContact ? Icons.call : Icons.people_alt_outlined,
              size: 16,
              color: contact.isServiceContact ? _kErrorRed : _kPrimaryBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  contact.number,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Selection radio
          InkWell(
            onTap: () {
              setState(() {
                selectedContactNumber =
                    isSelected ? null : contact.number;
              });
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _kPrimaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _kPrimaryGreen : Colors.black26,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          // Call button
          InkWell(
            onTap: () {
              // TODO: launch dialer with contact.number
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(color: _kPrimaryGreen, shape: BoxShape.circle),
              child: const Icon(Icons.call, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  // "Live Location Sharing" info card with blue outline.
  Widget _liveLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kPrimaryBlue.withOpacity(0.05),
        border: Border.all(color: _kPrimaryBlue.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.location_on_outlined, color: _kPrimaryBlue, size: 18),
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

  // "Call Police" + "Contact Support" buttons.
  Widget _actionButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: _secondaryButton(
            label: "Call Police",
            icon: Icons.call,
            color: _kPrimaryBlue,
            onTap: () {
              // TODO: launch dialer with 199
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _secondaryButton(
            label: "Contact Support",
            icon: Icons.chat_bubble_outline,
            color: _kPrimaryGreen,
            onTap: () {
              // TODO: navigate to support
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
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // "Activate Emergency" — grey/disabled until a contact is selected, red once enabled.
  Widget _activateButton() {
    return InkWell(
      onTap: canActivate
          ? () {
              // TODO: trigger emergency alert flow
            }
          : null,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: canActivate ? _kErrorRed : const Color(0xFFD9D9D9),
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