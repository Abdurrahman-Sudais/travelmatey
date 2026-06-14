import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../main.dart' show HomePage;

class RegisteredAddressPage extends StatefulWidget {
  const RegisteredAddressPage({super.key});

  @override
  State<RegisteredAddressPage> createState() =>
      _RegisteredAddressPageState();
}

class _RegisteredAddressPageState extends State<RegisteredAddressPage> {
  String? _state;
  String? _lga;
  final _wardCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _houseNumberCtrl = TextEditingController();

  final List<String> _states = [
    "Lagos",
    "Abuja (FCT)",
    "Kano",
    "Rivers",
    "Oyo",
    "Kaduna",
    "Ogun",
    "Enugu",
    "Delta",
    "Anambra",
  ];

  final Map<String, List<String>> _lgasByState = const {
    "Lagos": ["Eti-Osa", "Ikeja", "Surulere", "Lagos Island", "Ajeromi-Ifelodun"],
    "Abuja (FCT)": ["Abuja Municipal", "Gwagwalada", "Kuje", "Bwari"],
    "Kano": ["Kano Municipal", "Fagge", "Dala", "Gwale"],
    "Rivers": ["Port Harcourt", "Obio-Akpor", "Eleme"],
    "Oyo": ["Ibadan North", "Ibadan South-West", "Egbeda"],
    "Kaduna": ["Kaduna North", "Kaduna South", "Zaria"],
    "Ogun": ["Abeokuta South", "Ijebu Ode", "Sagamu"],
    "Enugu": ["Enugu East", "Enugu North", "Nsukka"],
    "Delta": ["Warri South", "Uvwie", "Sapele"],
    "Anambra": ["Awka South", "Onitsha North", "Nnewi North"],
  };

  bool get _canContinue =>
      _state != null &&
      _lga != null &&
      _wardCtrl.text.trim().isNotEmpty &&
      _streetCtrl.text.trim().isNotEmpty &&
      _houseNumberCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _wardCtrl.dispose();
    _streetCtrl.dispose();
    _houseNumberCtrl.dispose();
    super.dispose();
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
                      "Registered address",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _dropdownField(
                    label: "State",
                    value: _state,
                    options: _states,
                    onSelected: (v) => setState(() {
                      _state = v;
                      _lga = null;
                    }),
                  ),
                  const SizedBox(height: 14),
                  _dropdownField(
                    label: "Local government",
                    value: _lga,
                    options:
                        _state == null ? [] : _lgasByState[_state] ?? [],
                    onSelected: (v) => setState(() => _lga = v),
                    enabled: _state != null,
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: _wardCtrl,
                    hint: "Ward",
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: _streetCtrl,
                    hint: "Street",
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: _houseNumberCtrl,
                    hint: "House number",
                  ),
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

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String> onSelected,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled && options.isNotEmpty
          ? () => _showOptionsPicker(label, options, onSelected)
          : null,
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
              value ?? label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    value != null ? FontWeight.w600 : FontWeight.normal,
                color: value == null ? Colors.black38 : Colors.black87,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: enabled ? Colors.black54 : Colors.black26),
          ],
        ),
      ),
    );
  }

  void _showOptionsPicker(
      String title, List<String> options, ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: options
                .map((o) => ListTile(
                      title: Text(o),
                      onTap: () {
                        onSelected(o);
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
              // Registration complete — go to the app's home screen,
              // clearing the auth stack.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
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