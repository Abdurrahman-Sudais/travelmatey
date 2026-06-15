import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart';

class PostRidePage extends StatefulWidget {
  const PostRidePage({super.key});

  @override
  State<PostRidePage> createState() => _PostRidePageState();
}

class _PostRidePageState extends State<PostRidePage> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController();
  final _makeCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();

  bool _ac = true;
  bool _music = true;
  bool _charter = true;
  bool _smoking = true;

  String? _selectedDate;
  String? _selectedTime = '10:30 AM';

  final List<String> _nigerianStates = [
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa',
    'Benue', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti',
    'Enugu', 'FCT, Abuja', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano',
    'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger',
    'Ogun', 'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto',
    'Taraba', 'Yobe', 'Zamfara',
  ];

  final List<String> _times = [
    '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM', '10:00 AM',
    '10:30 AM', '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM',
    '03:00 PM', '04:00 PM', '05:00 PM', '06:00 PM',
  ];

  final List<String> _dates = List.generate(30, (i) {
    final now = DateTime.now().add(Duration(days: i + 1));
    return '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
  });

  String? _selectedFrom;
  String? _selectedTo;

  @override
  void dispose() {
    for (final c in [_fromCtrl, _toCtrl, _pickupCtrl, _dropoffCtrl,
      _priceCtrl, _seatsCtrl, _makeCtrl, _colorCtrl, _plateCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(context),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text('Post a Ride',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('Route Information'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _stateDropdown(
                            'Leaving From',
                            _selectedFrom,
                            (v) => setState(() => _selectedFrom = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _stateDropdown(
                            'Going To',
                            _selectedTo,
                            (v) => setState(() => _selectedTo = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _dropdownField(
                            'Date',
                            _dates,
                            _selectedDate,
                            (v) => setState(() => _selectedDate = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dropdownField(
                            'Time',
                            _times,
                            _selectedTime,
                            (v) => setState(() => _selectedTime = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _field('Pickup Point (Comma Separated)', _pickupCtrl),
                    const SizedBox(height: 10),
                    _field('Drop-off Point (Comma Separated)', _dropoffCtrl),
                    const SizedBox(height: 20),

                    _sectionLabel('Price & Capacity'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _field('Price Per Seat (₦)', _priceCtrl,
                              hint: '25000',
                              keyboardType: TextInputType.number),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field('Available Seats', _seatsCtrl,
                              hint: '6',
                              keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('Vehicle Information'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _field('Car Make & Model', _makeCtrl,
                              hint: 'Toyota, Sienna'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child:
                              _field('Car Color', _colorCtrl, hint: 'Grey'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _field('Plate Number', _plateCtrl, hint: 'XYZ-1234'),
                    const SizedBox(height: 20),

                    _sectionLabel('Amenities & Preferences'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _amenityCheck(
                            'AC', _ac, (v) => setState(() => _ac = v!)),
                        _amenityCheck('Music', _music,
                            (v) => setState(() => _music = v!)),
                        _amenityCheck('Charter', _charter,
                            (v) => setState(() => _charter = v!)),
                        _amenityCheck('Smoking', _smoking,
                            (v) => setState(() => _smoking = v!)),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _postRide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryGreen,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                              shadowColor: kPrimaryGreen.withOpacity(0.3),
                            ),
                            child: const Text('Post Ride',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const AppBottomNavBar(current: AppTab.secondary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _postRide() {
    if (_selectedFrom == null || _selectedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select departure and destination'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ride Posted!'),
        content: Text(
            'Your ride from $_selectedFrom to $_selectedTo has been posted successfully.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
            child: const Text('Great!',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text('Back', style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen));
  }

  Widget _stateDropdown(
      String hint, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint,
            style: const TextStyle(fontSize: 13, color: Colors.black38)),
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        items: _nigerianStates
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint ?? label,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kPrimaryGreen),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black38)),
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _amenityCheck(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: kPrimaryBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}