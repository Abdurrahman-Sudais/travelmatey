import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'purchase_success_page.dart';

class BuyAirtimePage extends StatefulWidget {
  final double availableBalance;
  const BuyAirtimePage({super.key, this.availableBalance = 25000});

  @override
  State<BuyAirtimePage> createState() => _BuyAirtimePageState();
}

class _BuyAirtimePageState extends State<BuyAirtimePage> {
  String? _selectedNetwork;
  final _phoneController = TextEditingController();
  final _customAmountController = TextEditingController();
  double? _selectedAmount;
  bool _saveAsBeneficiary = false;

  static const _networks = [
    {'name': 'MTN', 'icon': Icons.phone_iphone, 'color': Color(0xFFFFC107)},
    {'name': 'Airtel', 'icon': Icons.bar_chart, 'color': Color(0xFFFF6B35)},
    {'name': 'Glo', 'icon': Icons.public, 'color': Color(0xFF2196F3)},
    {'name': '9mobile', 'icon': Icons.phone, 'color': Color(0xFF424242)},
  ];

  static const _presetAmounts = [100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0];

  bool get _canProceed =>
      _selectedNetwork != null &&
      _phoneController.text.trim().length >= 10 &&
      (_selectedAmount != null || _customAmount > 0);

  double get _customAmount =>
      double.tryParse(_customAmountController.text) ?? 0;

  double get _finalAmount => _selectedAmount ?? _customAmount;

  void _onAmountTap(double amount) {
    setState(() {
      _selectedAmount = amount;
      _customAmountController.text = amount.toInt().toString();
    });
  }

  void _onCustomAmountChanged(String val) {
    final parsed = double.tryParse(val);
    setState(() {
      if (parsed != null && _presetAmounts.contains(parsed)) {
        _selectedAmount = parsed;
      } else {
        _selectedAmount = null;
      }
    });
  }

  void _buyAirtime() {
    if (!_canProceed) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PurchaseSuccessPage(
          type: PurchaseType.airtime,
          network: _selectedNetwork!,
          phoneNumber: _phoneController.text.trim(),
          amount: _finalAmount,
          previousBalance: widget.availableBalance,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _customAmountController.dispose();
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
                    const SizedBox(height: 14),
                    _amountSection(),
                    const SizedBox(height: 14),
                    _beneficiarySection(),
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
            color: kAmber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.phone_android, color: kAmber, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Buy Airtime",
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
                    onTap: () => setState(() => _selectedNetwork = name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? color : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.transparent),
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
                              color: isSelected ? Colors.white : Colors.black87,
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
          const Text("Enter the number to recharge",
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

  Widget _amountSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text("Amount",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(" *", style: TextStyle(color: Colors.red, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: _presetAmounts.map((amt) {
              final isSelected = _selectedAmount == amt;
              return GestureDetector(
                onTap: () => _onAmountTap(amt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryBlue : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "₦${amt.toInt()}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onCustomAmountChanged,
            decoration: InputDecoration(
              prefixText: "₦  ",
              prefixStyle:
                  const TextStyle(color: Colors.black54, fontSize: 14),
              hintText: "Enter custom amount",
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
          const SizedBox(height: 6),
          const Text(
            "Minimum: ₦50 • Maximum: ₦50,000",
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _beneficiarySection() {
    return _card(
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _saveAsBeneficiary = !_saveAsBeneficiary),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _saveAsBeneficiary
                    ? kPrimaryGreen.withOpacity(0.15)
                    : const Color(0xFF424242),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _saveAsBeneficiary
                  ? const Icon(Icons.check, color: kPrimaryGreen, size: 22)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Save as Beneficiary",
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text("Quick recharge next time",
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
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
            "You're sending ₦${_finalAmount.toInt()} airtime to ${_phoneController.text.trim()} on $_selectedNetwork",
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
        onTap: enabled ? _buyAirtime : null,
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
            "Buy Airtime",
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