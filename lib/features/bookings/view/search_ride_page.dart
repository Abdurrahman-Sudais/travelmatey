import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/features/bookings/view/search_results_page.dart';

class SearchRidePage extends StatefulWidget {
  const SearchRidePage({super.key});

  @override
  State<SearchRidePage> createState() => _SearchRidePageState();
}

class _SearchRidePageState extends State<SearchRidePage> {
  String? _from;
  String? _to;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();

  final List<String> _cities = const [
    "Abuja",
    "Lagos",
    "Ibadan",
    "Kano",
    "Port Harcourt",
  ];

  @override
  void dispose() {
    _dateController.dispose();
    _passengersController.dispose();
    super.dispose();
  }

  void _search() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          from: _from ?? "Lagos",
          to: _to ?? "Abuja",
          date: _dateController.text.isEmpty
              ? "Thursday, 1 January 2026"
              : _dateController.text,
          passengers: int.tryParse(_passengersController.text) ?? 1,
        ),
      ),
    );
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
                    _topBar(),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        "Search a Ride",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _filtersLink(),
                    const SizedBox(height: 20),
                    _fieldLabel("Leaving From", Icons.circle, kPrimaryGreen),
                    const SizedBox(height: 8),
                    _dropdownField(
                      hint: "Abuja",
                      value: _from,
                      onChanged: (v) => setState(() => _from = v),
                    ),
                    const SizedBox(height: 18),
                    _fieldLabel("Going To", Icons.location_on, kErrorRed),
                    const SizedBox(height: 8),
                    _dropdownField(
                      hint: "Lagos",
                      value: _to,
                      onChanged: (v) => setState(() => _to = v),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Date",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _dateController,
                      hint: "DD/MM/YYYY",
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Passengers",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _passengersController,
                      hint: "0",
                      icon: Icons.people_alt_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _search,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[500],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Search",
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chevron_left, size: 22, color: Colors.black87),
              Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, size: 24, color: Colors.black87),
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kErrorRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filtersLink() {
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.tune, size: 16, color: kPrimaryBlue),
          SizedBox(width: 6),
          Text(
            "Filters",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        Icon(icon, size: 14, color: color),
      ],
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.black38)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
          items: _cities
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        suffixIcon: Icon(icon, size: 18, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryBlue),
        ),
      ),
    );
  }
}