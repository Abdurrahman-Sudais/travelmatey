import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
//import 'package:travelmateeee/shared/widgets/kyc_required_dialog.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? departureState;
  String? destinationState;
  DateTime? travelDate;

  bool isRoundTrip = false;
  int passengerCount = 1;

  bool verifiedDriversOnly = true;
  bool instantBooking = false;
  bool femaleDrivers = false;
  bool charter = false;

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
                    "Search Rides",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Find the perfect ride for your journey",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel("Leaving From", required: true),
                  const SizedBox(height: 8),
                  _selectorField(
                    icon: Icons.adjust,
                    iconColor: kPrimaryBlue,
                    value: departureState,
                    placeholder: "Select departure state",
                    onTap: () => _pickState(isDeparture: true),
                  ),
                  const SizedBox(height: 18),
                  _fieldLabel("Going To", required: true),
                  const SizedBox(height: 8),
                  _selectorField(
                    icon: Icons.adjust,
                    iconColor: kPrimaryGreen,
                    value: destinationState,
                    placeholder: "Select destination state",
                    onTap: () => _pickState(isDeparture: false),
                  ),
                  const SizedBox(height: 18),
                  _fieldLabel("Travel Date", required: true),
                  const SizedBox(height: 8),
                  _dateField(),
                  const SizedBox(height: 18),
                  _roundTripCard(),
                  const SizedBox(height: 20),
                  const Text(
                    "Number of Passengers",
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _passengerCounter(),
                  const SizedBox(height: 20),
                  _preferencesCard(),
                  const SizedBox(height: 20),
                  _findRidesButton(),
                ],
              ),
            )),
    ), // Scaffold
    ); // SosScaffold
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

  Widget _fieldLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(
                text: " *", style: TextStyle(color: kErrorRed)),
        ],
      ),
    );
  }

  Widget _selectorField({
    required IconData icon,
    required Color iconColor,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration:
                  BoxDecoration(color: iconColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  fontSize: 14,
                  color: value != null ? Colors.black87 : Colors.black38,
                  fontWeight: value != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: Colors.black54),
            const SizedBox(width: 12),
            Text(
              travelDate == null
                  ? "Select travel date"
                  : "${travelDate!.day}/${travelDate!.month}/${travelDate!.year}",
              style: TextStyle(
                fontSize: 14,
                color:
                    travelDate != null ? Colors.black87 : Colors.black38,
                fontWeight: travelDate != null
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundTripCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sync_alt,
                color: kPrimaryBlue, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Round Trip (2-Way)",
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  "Book your return journey too.",
                  style:
                      TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          Switch(
            value: isRoundTrip,
            activeColor: kPrimaryGreen,
            onChanged: (v) => setState(() => isRoundTrip = v),
          ),
        ],
      ),
    );
  }

  Widget _passengerCounter() {
    return Row(
      children: [
        _counterButton(
          icon: Icons.remove,
          onTap: () {
            if (passengerCount > 1) {
              setState(() => passengerCount--);
            }
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Text(
              "$passengerCount",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _counterButton(
          icon: Icons.add,
          onTap: () => setState(() => passengerCount++),
        ),
      ],
    );
  }

  Widget _counterButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }

  Widget _preferencesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Preferences",
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _preferenceRow(
            label: "Verified Drivers Only",
            value: verifiedDriversOnly,
            onChanged: (v) =>
                setState(() => verifiedDriversOnly = v),
          ),
          _preferenceRow(
            label: "Instant Booking",
            value: instantBooking,
            onChanged: (v) => setState(() => instantBooking = v),
          ),
          _preferenceRow(
            label: "Female Drivers",
            value: femaleDrivers,
            onChanged: (v) => setState(() => femaleDrivers = v),
          ),
          _preferenceRow(
            label: "Charter (Full Vehicle)",
            value: charter,
            onChanged: (v) => setState(() => charter = v),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _preferenceRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13.5)),
          Switch(
            value: value,
            activeColor: kPrimaryGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _findRidesButton() {
    return InkWell(
      onTap: _onFindRides,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: kPrimaryGradient,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGreen.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              "Find Rides",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Actions ---

  Future<void> _pickState({required bool isDeparture}) async {
    const states = [
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
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: states
                .map((s) => ListTile(
                      title: Text(s),
                      onTap: () => Navigator.pop(context, s),
                    ))
                .toList(),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() {
        if (isDeparture) {
          departureState = selected;
        } else {
          destinationState = selected;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => travelDate = picked);
    }
  }

  void _onFindRides() {
    if (departureState == null ||
        destinationState == null ||
        travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields."),
          backgroundColor: kErrorRed,
        ),
      );
      return;
    }
    // TODO: navigate to results page with search params
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Searching $departureState → $destinationState on ${travelDate!.day}/${travelDate!.month}/${travelDate!.year}"),
        backgroundColor: kPrimaryGreen,
      ),
    );
  }
}