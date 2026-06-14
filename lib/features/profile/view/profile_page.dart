import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/shared/widgets/edit_profile_sheet.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart';
import 'package:travelmateeee/features/profile/view/notification_settings_page.dart';
import 'package:travelmateeee/features/support/view/help_support_page.dart';
import 'package:travelmateeee/features/profile/view/pdf_export_manager_page.dart';
import 'package:travelmateeee/features/auth/view/kyc_page.dart';
import 'package:travelmateeee/features/rides/view/ride_history_page.dart';
import 'referral_page.dart';
import 'promo_code_page.dart';
import 'privacy_security_page.dart';
import 'package:travelmateeee/features/auth/view/auth_diagnostics_page.dart';
import 'terms_policies_page.dart';
import 'about_page.dart';
import 'package:travelmateeee/features/home/view/home_page.dart' show activeRoleNotifier, HomePage, RoleAwareHome;
import 'package:travelmateeee/core/base/active_role.dart';

enum AppearanceMode { light, dark, system }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ActiveRole activeRole;
  AppearanceMode appearanceMode = AppearanceMode.light;

  @override
  void initState() {
    super.initState();
    activeRole = activeRoleNotifier.value;
    activeRoleNotifier.addListener(_onRoleChanged);
  }

  void _onRoleChanged() {
    setState(() => activeRole = activeRoleNotifier.value);
  }

  @override
  void dispose() {
    activeRoleNotifier.removeListener(_onRoleChanged);
    super.dispose();
  }

  void _switchRole(ActiveRole role) {
    if (role == activeRole) return;
    setState(() => activeRole = role);
    activeRoleNotifier.value = role;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleAwareHome()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDriver = activeRole == ActiveRole.driver;

    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(),
                    const SizedBox(height: 12),
                    const Text(
                      "Profile & Settings",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _profileCard(),
                    const SizedBox(height: 16),
                    // Vehicle info only shown for drivers
                    if (isDriver) ...[
                      _vehicleCard(),
                      const SizedBox(height: 16),
                    ],
                    _appearanceCard(),
                    const SizedBox(height: 16),
                    _settingsCard(),
                    const SizedBox(height: 20),
                    _logoutButton(),
                    const SizedBox(height: 12),
                    _deleteAccountButton(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: const AppBottomNavBar(current: AppTab.profile),
            ),
          ],
        ),
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

  Widget _profileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "User",
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.star,
                            size: 15, color: Color(0xFFF59E0B)),
                        SizedBox(width: 4),
                        Text(
                          "4.8 · 47 trips",
                          style: TextStyle(
                              fontSize: 12.5, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Member since January 2024",
                      style: TextStyle(
                          fontSize: 11.5, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          _contactRow(
              icon: Icons.email_outlined, text: "user@example.com"),
          const SizedBox(height: 10),
          _contactRow(
              icon: Icons.call_outlined, text: "+234XXXXXXXXXX"),
          const SizedBox(height: 16),
          _activeRoleRow(),
          const SizedBox(height: 16),
          _editProfileButton(),
        ],
      ),
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: kPrimaryGreen,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.person, color: Colors.white, size: 34),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: kPrimaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.camera_alt,
                  color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.black54),
        const SizedBox(width: 10),
        Text(text,
            style:
                const TextStyle(fontSize: 13.5, color: Colors.black87)),
      ],
    );
  }

  Widget _activeRoleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.person_outline, size: 17, color: Colors.black87),
            SizedBox(width: 8),
            Text(
              "Active Role",
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              _roleChip("Driver", ActiveRole.driver),
              _roleChip("Rider", ActiveRole.rider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleChip(String label, ActiveRole role) {
    final bool isActive = activeRole == role;
    return InkWell(
      onTap: () => _switchRole(role),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _editProfileButton() {
    return InkWell(
      onTap: () => showEditProfileSheet(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Edit Profile",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
      ),
    );
  }

  // ── Vehicle card (driver only) ──────────────────────────────────────────

  Widget _vehicleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vehicle Information",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kPrimaryBlue),
          ),
          const SizedBox(height: 14),
          _vehicleDetailRow("Make & Model", "Toyota Sienna"),
          _vehicleDetailRow("Year", "2020"),
          _vehicleDetailRow("Color", "Grey"),
          _vehicleDetailRow("Plate Number", "ABC-123-XY"),
          _vehicleDetailRow("Seats", "6", isLast: true),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showEditVehicleSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Edit Vehicle",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleDetailRow(String label, String value,
      {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
        if (!isLast) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _showEditVehicleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EditVehicleSheet(),
    );
  }

  // ── Appearance card ─────────────────────────────────────────────────────

  Widget _appearanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Appearance",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kPrimaryBlue),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _appearanceTab(
                  icon: Icons.wb_sunny_outlined,
                  label: "Light",
                  mode: AppearanceMode.light,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _appearanceTab(
                  icon: Icons.nightlight_outlined,
                  label: "Dark",
                  mode: AppearanceMode.dark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _appearanceTab(
                  icon: Icons.desktop_windows_outlined,
                  label: "System",
                  mode: AppearanceMode.system,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appearanceTab({
    required IconData icon,
    required String label,
    required AppearanceMode mode,
  }) {
    final bool isSelected = appearanceMode == mode;
    return InkWell(
      onTap: () => setState(() => appearanceMode = mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimaryBlue : const Color(0xFFE6E6E6),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? kPrimaryBlue : Colors.black54),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? kPrimaryBlue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Settings list ────────────────────────────────────────────────────────

  Widget _settingsCard() {
    final items = <_SettingsItem>[
      _SettingsItem(Icons.shield_outlined, "KYC Verification"),
      _SettingsItem(Icons.description_outlined, "Ride History"),
      _SettingsItem(Icons.people_outline, "Referral Program"),
      _SettingsItem(Icons.local_offer_outlined, "Promo Codes"),
      _SettingsItem(Icons.lock_outline, "Privacy & Security"),
      _SettingsItem(
          Icons.notifications_outlined, "Notification Settings"),
      _SettingsItem(Icons.help_outline, "Help & Support"),
      _SettingsItem(
          Icons.verified_user_outlined, "Auth Diagnostics"),
      _SettingsItem(
          Icons.file_download_outlined, "Export PDF Presentation",
          iconColor: kPrimaryGreen),
      _SettingsItem(Icons.article_outlined, "Terms & Policies"),
      _SettingsItem(Icons.info_outline, "About"),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return _settingsRow(
            icon: item.icon,
            label: item.label,
            iconColor: item.iconColor,
            isLast: index == items.length - 1,
            onTap: () {
              if (item.label == "Notification Settings") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationSettingsPage()),
                );
              } else if (item.label == "Help & Support") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HelpSupportPage()),
                );
              } else if (item.label == "Export PDF Presentation") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PdfExportManagerPage()),
                );
              } else if (item.label == "KYC Verification") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KycPage()),
                );
              } else if (item.label == "Ride History") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RideHistoryPage()),
                );
              } else if (item.label == "Referral Program") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReferralPage()),
                );
              } else if (item.label == "Promo Codes") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PromoCodePage()),
                );
              } else if (item.label == "Privacy & Security") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PrivacySecurityPage()),
                );
              } else if (item.label == "Auth Diagnostics") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AuthDiagnosticsPage()),
                );
              } else if (item.label == "Terms & Policies") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TermsPoliciesPage()),
                );
              } else if (item.label == "About") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              }
            },
          );
        }),
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String label,
    Color? iconColor,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: iconColor ?? Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kErrorRed.withOpacity(0.4)),
        ),
        child: const Text(
          "Logout",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kErrorRed),
        ),
      ),
    );
  }

  Widget _deleteAccountButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kErrorRed.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kErrorRed.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.delete_outline, size: 17, color: kErrorRed),
            SizedBox(width: 8),
            Text(
              "Delete My Account",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kErrorRed),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit Vehicle Bottom Sheet ────────────────────────────────────────────────

class _EditVehicleSheet extends StatefulWidget {
  const _EditVehicleSheet();

  @override
  State<_EditVehicleSheet> createState() => _EditVehicleSheetState();
}

class _EditVehicleSheetState extends State<_EditVehicleSheet> {
  final _makeCtrl = TextEditingController(text: "Toyota");
  final _modelCtrl = TextEditingController(text: "Sienna");
  final _yearCtrl = TextEditingController(text: "2020");
  final _colorCtrl = TextEditingController(text: "Grey");
  final _plateCtrl = TextEditingController(text: "ABC-123-XY");
  final _seatsCtrl = TextEditingController(text: "6");

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    _seatsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: kPrimaryGradient,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Edit Vehicle",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding:
                      EdgeInsets.fromLTRB(16, 20, 16, bottom + 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Basic Information",
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryBlue),
                      ),
                      const SizedBox(height: 14),
                      _field("Make", _makeCtrl),
                      const SizedBox(height: 14),
                      _field("Model", _modelCtrl),
                      const SizedBox(height: 14),
                      _field("Year", _yearCtrl,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 14),
                      _field("Color", _colorCtrl),
                      const SizedBox(height: 14),
                      _field("Plate Number", _plateCtrl),
                      const SizedBox(height: 14),
                      _field("Seats", _seatsCtrl,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 28),
                      _saveButton(),
                      const SizedBox(height: 12),
                      _cancelButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style:
              const TextStyle(fontSize: 13.5, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return InkWell(
      onTap: () {
        // TODO: submit vehicle changes
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: kPrimaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGreen.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        child: const Text(
          "Cancel",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final Color? iconColor;

  _SettingsItem(this.icon, this.label, {this.iconColor});
}