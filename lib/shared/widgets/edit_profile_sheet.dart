import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/data/repositories/user_repository.dart';

/// Call this to show the Edit Profile bottom sheet.
Future<void> showEditProfileSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EditProfileSheet(),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _lgaCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  UserRepository get _userRepo => Get.find<UserRepository>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _userRepo.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = user.name;
        _emailCtrl.text = user.email;
        _phoneCtrl.text = user.phone;
        _streetCtrl.text = user.street;
        _cityCtrl.text = user.city;
        _stateCtrl.text = user.state;
        _lgaCtrl.text = user.lga;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _userRepo.updateAddress(
        street: _streetCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        lga: _lgaCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      Get.snackbar(
        'Profile updated',
        'Your address has been saved.',
        backgroundColor: kPrimaryGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Save failed',
        e.toString(),
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _lgaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
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
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryBlue),
                      )
                    : SingleChildScrollView(
                        controller: scrollCtrl,
                        padding: EdgeInsets.fromLTRB(16, 20, 16, bottom + 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel("Basic Information", kPrimaryBlue),
                            const SizedBox(height: 14),
                            _readonlyField(
                              label: "Name",
                              controller: _nameCtrl,
                              hint: "Contact support to change your name",
                            ),
                            const SizedBox(height: 14),
                            _readonlyField(
                              label: "Email",
                              controller: _emailCtrl,
                              hint: "Contact support to change your email",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            _readonlyField(
                              label: "Phone",
                              controller: _phoneCtrl,
                              hint: "Contact support to change your phone number",
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 22),
                            _sectionLabel("Registered Address (Editable)", null),
                            const SizedBox(height: 14),
                            _editableField(
                              label: "Street Address",
                              controller: _streetCtrl,
                            ),
                            const SizedBox(height: 14),
                            _editableField(
                              label: "City",
                              controller: _cityCtrl,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _editableField(
                                    label: "State",
                                    controller: _stateCtrl,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _editableField(
                                    label: "LGA",
                                    controller: _lgaCtrl,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _sectionLabel(String text, Color? color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.black87,
      ),
    );
  }

  Widget _readonlyField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13.5, color: Colors.black54),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
            ),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
          ),
        ),
      ],
    );
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13.5, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
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
      onTap: _saving ? null : _save,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: kPrimaryGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
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
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
