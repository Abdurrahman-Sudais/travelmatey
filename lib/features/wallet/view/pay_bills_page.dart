import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';

class _BillCategory {
  final String label;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<_BillProvider> providers;

  const _BillCategory({
    required this.label,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.providers,
  });
}

class _BillProvider {
  final String name;
  final String emoji;

  const _BillProvider({required this.name, required this.emoji});
}

/// Pay Bills page.
class PayBillsPage extends StatefulWidget {
  final double availableBalance;

  const PayBillsPage({super.key, required this.availableBalance});

  @override
  State<PayBillsPage> createState() => _PayBillsPageState();
}

class _PayBillsPageState extends State<PayBillsPage> {
  late double _balance;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  int? _selectedCategoryIndex;
  int? _selectedProviderIndex;

  bool _showSuccess = false;
  double _amountPaid = 0;
  String _accountNumberPaid = "";

  static const List<_BillCategory> _categories = [
    _BillCategory(
      label: "Electricity",
      emoji: "⚡",
      icon: Icons.bolt,
      color: kAmber,
      providers: [
        _BillProvider(name: "Eko Electricity (EKEDC)", emoji: "⚡"),
        _BillProvider(name: "Ikeja Electric (IKEDC)", emoji: "⚡"),
        _BillProvider(name: "Abuja Electricity (AEDC)", emoji: "⚡"),
        _BillProvider(name: "Port Harcourt Electricity (PHED)", emoji: "⚡"),
        _BillProvider(name: "Kano Electricity (KEDCO)", emoji: "⚡"),
      ],
    ),
    _BillCategory(
      label: "Cable TV",
      emoji: "📺",
      icon: Icons.tv,
      color: Color(0xFF9333EA),
      providers: [
        _BillProvider(name: "DSTV", emoji: "📺"),
        _BillProvider(name: "GOtv", emoji: "📺"),
        _BillProvider(name: "StarTimes", emoji: "📺"),
      ],
    ),
    _BillCategory(
      label: "Internet",
      emoji: "🌐",
      icon: Icons.public,
      color: kPrimaryBlue,
      providers: [
        _BillProvider(name: "Spectranet", emoji: "🌐"),
        _BillProvider(name: "Smile", emoji: "🌐"),
        _BillProvider(name: "IPNX", emoji: "🌐"),
      ],
    ),
    _BillCategory(
      label: "Education",
      emoji: "🎓",
      icon: Icons.school,
      color: kPrimaryGreen,
      providers: [
        _BillProvider(name: "WAEC", emoji: "🎓"),
        _BillProvider(name: "JAMB", emoji: "🎓"),
        _BillProvider(name: "NECO", emoji: "🎓"),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _balance = widget.availableBalance;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  String _formatNaira(double value) {
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return "₦$buffer";
  }

  bool get _canPay {
    if (_selectedCategoryIndex == null || _selectedProviderIndex == null) {
      return false;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return false;
    if (amount > _balance) return false;
    if (_accountController.text.trim().isEmpty) return false;
    return true;
  }

  void _payBill() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (!_canPay) return;

    setState(() {
      _balance -= amount;
      _amountPaid = amount;
      _accountNumberPaid = _accountController.text.trim();
      _showSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: _showSuccess ? _successView() : _formView(),
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
          Icon(Icons.chevron_left, size: 22, color: Colors.black54),
          Text("Back", style: TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kPrimaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: kPrimaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pay Bills",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  "Balance: ${_formatNaira(_balance)}",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Select Bill Category"),
              const SizedBox(height: 12),
              _categoryGrid(),
            ],
          ),
        ),
        if (_selectedCategoryIndex != null) const SizedBox(height: 14),
        if (_selectedCategoryIndex != null)
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Select Provider"),
                const SizedBox(height: 12),
                ..._categories[_selectedCategoryIndex!].providers
                    .asMap()
                    .entries
                    .map((entry) => _providerTile(entry.key, entry.value)),
              ],
            ),
          ),
        if (_selectedProviderIndex != null) const SizedBox(height: 14),
        if (_selectedProviderIndex != null)
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Account / Meter / Smart Card Number"),
                const SizedBox(height: 8),
                _textField(
                  controller: _accountController,
                  hint: "Enter number",
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                _label("Enter Amount"),
                const SizedBox(height: 8),
                _textField(
                  controller: _amountController,
                  hint: "0.00",
                  prefixText: "₦  ",
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        _payButton(),
      ],
    );
  }

  Widget _label(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        children: const [
          TextSpan(
            text: " *",
            style: TextStyle(color: kErrorRed, fontWeight: FontWeight.bold),
          ),
        ],
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _categoryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: _categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final isSelected = _selectedCategoryIndex == index;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedCategoryIndex = index;
              _selectedProviderIndex = null;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? category.color : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _providerTile(int index, _BillProvider provider) {
    final isSelected = _selectedProviderIndex == index;
    final category = _categories[_selectedCategoryIndex!];
    return InkWell(
      onTap: () => setState(() => _selectedProviderIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withOpacity(0.12)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? category.color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(provider.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(
              provider.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        prefixText: prefixText,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _payButton() {
    return InkWell(
      onTap: _canPay ? _payBill : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _canPay ? kPrimaryGreen : const Color(0xFFCCCCCC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "Pay Bill",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _successView() {
    final category = _categories[_selectedCategoryIndex!];
    final provider = category.providers[_selectedProviderIndex!];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(height: 80),
        Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: kPrimaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: kPrimaryGreen,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your ${category.label} bill has been paid",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _receiptRow("Service", provider.name),
                      const SizedBox(height: 10),
                      _receiptRow("Account Number", _accountNumberPaid),
                      const SizedBox(height: 10),
                      _receiptRow(
                        "Amount Paid",
                        _formatNaira(_amountPaid),
                        valueColor: kPrimaryGreen,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      _receiptRow(
                        "New Balance",
                        _formatNaira(_balance),
                        valueColor: kPrimaryBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => Navigator.pop(context, _balance),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), kPrimaryGreen],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _receiptRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}