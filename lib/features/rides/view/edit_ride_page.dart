import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'my_rides_page.dart';

class EditRidePage extends StatefulWidget {
  final RideItem ride;
  const EditRidePage({super.key, required this.ride});

  @override
  State<EditRidePage> createState() => _EditRidePageState();
}

class _EditRidePageState extends State<EditRidePage> {
  late final TextEditingController _fromCtrl;
  late final TextEditingController _toCtrl;
  late final TextEditingController _pickupCtrl;
  late final TextEditingController _dropoffCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _seatsCtrl;
  late final TextEditingController _makeCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _plateCtrl;

  bool _ac = true;
  bool _music = true;
  bool _charter = false;
  bool _smoking = false;

  String? _selectedDate;
  String? _selectedTime;

  final List<String> _times = [
    '06:00 AM',
    '07:00 AM',
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
  ];

  final List<String> _dates = [
    '12/25/2024',
    '12/26/2024',
    '12/27/2024',
    '12/28/2024',
    '12/29/2024',
    '12/30/2024',
    '12/31/2024',
  ];

  @override
  void initState() {
    super.initState();
    _fromCtrl = TextEditingController(text: widget.ride.from);
    _toCtrl = TextEditingController(text: widget.ride.to);
    _pickupCtrl = TextEditingController(text: 'Utako, Market, Abuja');
    _dropoffCtrl = TextEditingController(text: 'Ikeja, Ojota, Berger');
    _priceCtrl = TextEditingController(text: '25000');
    _seatsCtrl = TextEditingController(
      text: widget.ride.seats
          .split('/')
          .last
          .replaceAll(RegExp(r'[^0-9]'), '')
          .trim(),
    );
    _makeCtrl = TextEditingController(text: 'Toyota Sienna');
    _colorCtrl = TextEditingController(text: 'Grey');
    _plateCtrl = TextEditingController();
    _selectedDate = _dates.first;
    _selectedTime = '10:30 AM';
  }

  @override
  void dispose() {
    for (final c in [
      _fromCtrl,
      _toCtrl,
      _pickupCtrl,
      _dropoffCtrl,
      _priceCtrl,
      _seatsCtrl,
      _makeCtrl,
      _colorCtrl,
      _plateCtrl,
    ]) {
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
                      child: Text(
                        'Edit Ride',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('Route Information'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _field('Leaving From', _fromCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _field('Going To', _toCtrl)),
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
                          child: _field(
                            'Price Per Seat (₦)',
                            _priceCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'Available Seats',
                            _seatsCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('Vehicle Information'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _field('Car Make & Model', _makeCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _field('Car Color', _colorCtrl)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _field('Plate Number', _plateCtrl),
                    const SizedBox(height: 20),

                    _sectionLabel('Amenities & Preferences'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _amenityCheck(
                          'AC',
                          _ac,
                          (v) => setState(() => _ac = v!),
                        ),
                        _amenityCheck(
                          'Music',
                          _music,
                          (v) => setState(() => _music = v!),
                        ),
                        _amenityCheck(
                          'Charter',
                          _charter,
                          (v) => setState(() => _charter = v!),
                        ),
                        _amenityCheck(
                          'Smoking',
                          _smoking,
                          (v) => setState(() => _smoking = v!),
                        ),
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ride updated successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: kPrimaryGreen,
      ),
    );
  }

  Widget _field(
    String hint,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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

  Widget _dropdownField(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _amenityCheck(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: kPrimaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
