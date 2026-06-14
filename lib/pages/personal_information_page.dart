import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'registered_address_page.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState
    extends State<PersonalInformationPage> {
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  DateTime? _dob;
  String? _gender;

  final List<String> _genders = ["Male", "Female"];

  bool get _canContinue =>
      _firstNameCtrl.text.trim().isNotEmpty &&
      _surnameCtrl.text.trim().isNotEmpty &&
      _dob != null &&
      _gender != null;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _surnameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          _backgroundRipples(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      "Personal information",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _textField(
                    controller: _firstNameCtrl,
                    hint: "First name",
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: _middleNameCtrl,
                    hint: "Middle name (Optional)",
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: _surnameCtrl,
                    hint: "Surname",
                  ),
                  const SizedBox(height: 14),
                  _dateField(),
                  const SizedBox(height: 14),
                  _genderField(),
                  const SizedBox(height: 28),
                  const Center(
                    child: Text(
                      "Note: Real names and KYC details are "
                      "confidential. No users can access these "
                      "information",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.black45,
                          height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _continueButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundRipples() {
    return Positioned(
      top: -100,
      left: -100,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.4,
          child: SizedBox(
            width: 360,
            height: 360,
            child: CustomPaint(painter: _RipplePainter()),
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

  Widget _textField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFEDEDED),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dob == null
                  ? "Date of birth"
                  : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
              style: TextStyle(
                fontSize: 14,
                color: _dob == null ? Colors.black38 : Colors.black87,
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _genderField() {
    return InkWell(
      onTap: () => _showGenderPicker(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _gender ?? "Gender",
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    _gender != null ? FontWeight.w600 : FontWeight.normal,
                color: _gender == null ? Colors.black38 : Colors.black87,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _genders
                .map((g) => ListTile(
                      title: Text(g),
                      onTap: () {
                        setState(() => _gender = g);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _continueButton() {
    final bool enabled = _canContinue;
    return InkWell(
      onTap: enabled
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RegisteredAddressPage()),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryBlue : const Color(0xFF9CA3AF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Continue",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(0, 0);
    for (int i = 1; i <= 6; i++) {
      canvas.drawCircle(center, i * 30.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}