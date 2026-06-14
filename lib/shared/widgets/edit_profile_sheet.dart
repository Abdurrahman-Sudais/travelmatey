import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';

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
  // Basic info controllers (read-only — user must contact support)
  final _nameCtrl =
      TextEditingController(text: "Michael Adeyemi");
  final _emailCtrl =
      TextEditingController(text: "michael.adeyemi@example.com");
  final _phoneCtrl =
      TextEditingController(text: "+234 803 123 4567");

  // Editable address fields
  final _streetCtrl =
      TextEditingController(text: "15 Admiralty Way, Lekki Phase 1");
  final _cityCtrl = TextEditingController(text: "Lagos");
  final _stateCtrl = TextEditingController(text: "Lagos");
  final _lgaCtrl = TextEditingController(text: "Eti-Osa");

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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
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
                    // Drag handle
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
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Edit Profile",
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
                      Row(
                        children: [
                          _sectionLabel(
                              "Registered Address (Editable)", null),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kPrimaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: kPrimaryBlue.withOpacity(0.3)),
                            ),
                            child: const Text(
                              "KYC Required",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: kPrimaryBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
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
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13.5, color: Colors.black54),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 11, color: Colors.black38),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            hint,
            style:
                const TextStyle(fontSize: 10.5, color: Colors.black38),
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
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13.5, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.1)),
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
        // TODO: submit changes
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