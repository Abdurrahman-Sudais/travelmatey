import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'purchase_success_page.dart';

class _DataPlan {
  final String size;
  final String validity;
  final double price;
  const _DataPlan(this.size, this.validity, this.price);
}

class BuyDataPage extends StatefulWidget {
  final double availableBalance;
  const BuyDataPage({super.key, this.availableBalance = 25000});

  @override
  State<BuyDataPage> createState() => _BuyDataPageState();
}

class _BuyDataPageState extends State<BuyDataPage> {
  String? _selectedNetwork;
  final _phoneController = TextEditingController();
  _DataPlan? _selectedPlan;

  static const _networks = [
    {'name': 'MTN', 'icon': Icons.phone_iphone, 'color': Color(0xFFFFC107)},
    {'name': 'Airtel', 'icon': Icons.bar_chart, 'color': Color(0xFFFF6B35)},
    {'name': 'Glo', 'icon': Icons.public, 'color': Color(0xFF2196F3)},
    {'name': '9mobile', 'icon': Icons.phone, 'color': Color(0xFF424242)},
  ];

  static const _plans = [
    _DataPlan('500MB', 'Valid for 30 Days', 500),
    _DataPlan('1GB', 'Valid for 30 Days', 1000),
    _DataPlan('2GB', 'Valid for 30 Days', 2000),
    _DataPlan('3GB', 'Valid for 30 Days', 3000),
    _DataPlan('5GB', 'Valid for 30 Days', 5000),
    _DataPlan('10GB', 'Valid for 30 Days', 10000),
  ];

  bool get _canProceed =>
      _selectedNetwork != null &&
      _phoneController.text.trim().length >= 10 &&
      _selectedPlan != null;

  void _buyData() {
    if (!_canProceed) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PurchaseSuccessPage(
          type: PurchaseType.data,
          network: _selectedNetwork!,
          phoneNumber: _phoneController.text.trim(),
          amount: _selectedPlan!.price,
          previousBalance: widget.availableBalance,
          dataBundle: _selectedPlan!.size,
          validity: _selectedPlan!.validity,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(context),
                    const SizedBox(height: 16),
                    _header(),
                    const SizedBox(height: 20),
                    _networkSection(),
                    const SizedBox(height: 14),
                    _phoneSection(),
                    if (_selectedNetwork != null &&
                        _phoneController.text.trim().length >= 10) ...[
                      const SizedBox(height: 14),
                      _dataPlansSection(),
                    ],
                    if (_canProceed) ...[
                      const SizedBox(height: 14),
                      _transactionSummary(),
                    ],
                  ],
                ),
              ),
            ),
            _buyButton(),
          ],
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
          Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: kPrimaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.terminal, color: kPrimaryGreen, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Buy Data",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Balance: ₦${widget.availableBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _networkSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text("Select Network",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(" *", style: TextStyle(color: Colors.red, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _networks.map((n) {
              final name = n['name'] as String;
              final isSelected = _selectedNetwork == name;
              final color = n['color'] as Color;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedNetwork = name;
                      _selectedPlan = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? color : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            n['icon'] as IconData,
                            size: 28,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _phoneSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text("Phone Number",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(" *", style: TextStyle(color: Colors.red, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Enter the number to send data",
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: false,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "080XXXXXXXXX",
              hintStyle: const TextStyle(color: Colors.black38),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kPrimaryGreen.withOpacity(0.5)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataPlansSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text("Select Data Plan",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(" *", style: TextStyle(color: Colors.red, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          ..._plans.map((plan) {
            final isSelected = _selectedPlan == plan;
            return GestureDetector(
              onTap: () => setState(() => _selectedPlan = plan),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? kPrimaryBlue.withOpacity(0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? kPrimaryBlue : const Color(0xFFE0E0E0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.size,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? kPrimaryBlue
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.validity,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₦${plan.price.toInt()}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? kPrimaryBlue : kPrimaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _transactionSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: kPrimaryBlue, width: 3),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Transaction Summary",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            "You're sending ${_selectedPlan!.size} data to ${_phoneController.text.trim()} on $_selectedNetwork for ₦${_selectedPlan!.price.toInt()}",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buyButton() {
    final enabled = _canProceed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GestureDetector(
        onTap: enabled ? _buyData : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF1565C0), kPrimaryGreen],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: enabled ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            "Buy Data",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}