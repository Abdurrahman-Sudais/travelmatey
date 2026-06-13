import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/emergency_sos.dart';
import '../widgets/edit_profile_sheet.dart';
import '../main.dart' show activeRoleNotifier;

enum ActiveRole { driver, rider }

enum AppearanceMode { light, dark, system }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mirror the global notifier value locally so the UI reacts immediately.
  late ActiveRole activeRole;
  AppearanceMode appearanceMode = AppearanceMode.light;

  @override
  void initState() {
    super.initState();
    activeRole = activeRoleNotifier.value;
  }

  void _switchRole(ActiveRole role) {
    if (role == activeRole) return;
    setState(() => activeRole = role);
    activeRoleNotifier.value = role;

    // Pop all the way back to the root RoleAwareHome which will rebuild.
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                  "Profile & Settings",
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _profileCard(),
                const SizedBox(height: 16),
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
            style: const TextStyle(
                fontSize: 13.5, color: Colors.black87)),
      ],
    );
  }

  Widget _activeRoleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.person_outline,
                size: 17, color: Colors.black87),
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
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryGreen : Colors.transparent,
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
            color: isSelected
                ? kPrimaryBlue
                : const Color(0xFFE6E6E6),
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
  }) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom:
                      BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 19,
                color: iconColor ?? Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600),
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

class _SettingsItem {
  final IconData icon;
  final String label;
  final Color? iconColor;

  _SettingsItem(this.icon, this.label, {this.iconColor});
}