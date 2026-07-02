import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/keyboard_aware_scaffold.dart';
import 'package:travelmateeee/data/repositories/wallet_repository.dart';

/// Card Funding page.
class CardFundingPage extends StatefulWidget {
  final double currentBalance;

  const CardFundingPage({super.key, required this.currentBalance});

  @override
  State<CardFundingPage> createState() => _CardFundingPageState();
}

class _CardFundingPageState extends State<CardFundingPage> {
  late double _balance;

  final TextEditingController _amountController = TextEditingController();

  bool _showSuccess = false;
  double _amountFunded = 0;
  bool _isSubmitting = false;
  bool _isVerifying = false;
  WalletFundingSession? _fundingSession;

  static const List<int> _quickAmounts = [1000, 5000, 10000, 20000];

  @override
  void initState() {
    super.initState();
    _balance = widget.currentBalance;
  }

  @override
  void dispose() {
    _amountController.dispose();
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

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  bool get _canPay {
    if (_isSubmitting) return false;
    if (_amount < 100 || _amount > 1000000) return false;
    return true;
  }

  Future<void> _pay() async {
    if (!_canPay) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = Get.find<WalletRepository>();
      final session = await repo.initializeWalletFunding(amount: _amount);
      final launched = await launchUrl(
        Uri.parse(session.authorizationUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Could not open Paystack checkout.');
      }
      if (!mounted) return;
      setState(() => _fundingSession = session);
      Get.snackbar(
        'Checkout opened',
        'Complete payment in Paystack, then return here to verify it.',
        backgroundColor: kPrimaryBlue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start payment: $e',
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _verifyPayment() async {
    final session = _fundingSession;
    if (session == null || _isVerifying) return;
    setState(() => _isVerifying = true);
    try {
      final repo = Get.find<WalletRepository>();
      final wallet = await repo.verifyWalletPayment(
        reference: session.reference,
      );
      if (!mounted) return;
      setState(() {
        _amountFunded = _amount;
        _balance = wallet.balance;
        _showSuccess = true;
        _fundingSession = null;
      });
    } catch (e) {
      Get.snackbar(
        'Verification failed',
        'Payment could not be verified yet: $e',
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareFormScaffold(
      showSos: true,
      body: KeyboardAwareScrollBody(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (_showSuccess) _successView() else _formView(),
        ],
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () => Navigator.maybePop(context, _balance),
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
        const SizedBox(height: 8),
        const Text(
          "Card Funding",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Fund your wallet with debit or credit card",
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 18),
        _balanceCard(),
        const SizedBox(height: 18),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Amount to Fund"),
              const SizedBox(height: 8),
              _textField(
                controller: _amountController,
                hint: "0.00",
                prefixText: "₦  ",
                keyboardType: TextInputType.number,
                fontSize: 22,
              ),
              const SizedBox(height: 6),
              const Text(
                "Min: ₦100 • Max: ₦1,000,000",
                style: TextStyle(fontSize: 11.5, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              const Text(
                "Quick Select",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _quickSelectRow(),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              const Text(
                "Paystack Checkout",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              const Text(
                "Card details are entered only on Paystack's secure checkout page. TravelMate never stores your card number or CVV.",
                style: TextStyle(fontSize: 12.5, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              _payButton(),
              if (_fundingSession != null) ...[
                const SizedBox(height: 12),
                _verifyButton(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _securePaymentCard(),
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), kPrimaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CURRENT BALANCE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatNaira(_balance),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickSelectRow() {
    return Row(
      children: _quickAmounts.map((amount) {
        final isSelected = _amount == amount.toDouble();
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _amountController.text = amount.toString();
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? kPrimaryBlue.withValues(alpha: 0.12)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? kPrimaryBlue : Colors.transparent,
                  ),
                ),
                child: Text(
                  "₦${amount ~/ 1000}k",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? kPrimaryBlue : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? prefixText,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    double fontSize = 14,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      onChanged: (_) => setState(() {}),
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        prefixText: prefixText,
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.black38)
            : null,
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
      onTap: _canPay ? _pay : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _canPay ? kPrimaryGreen : const Color(0xFFCCCCCC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                "Open Paystack ${_formatNaira(_amount)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _verifyButton() {
    return InkWell(
      onTap: _isVerifying ? null : _verifyPayment,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isVerifying ? const Color(0xFFCCCCCC) : kPrimaryBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Text(
                "I've completed payment - verify now",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _securePaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock, color: kPrimaryGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Secure Payment",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Your card details are encrypted and secure. We use industry-standard SSL encryption.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _successView() {
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
                  color: Colors.black.withValues(alpha: 0.06),
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
                    color: kPrimaryGreen.withValues(alpha: 0.12),
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
                  "Funding Successful!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Your wallet has been funded",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Colors.black54),
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
                      _receiptRow(
                        "Amount Funded",
                        _formatNaira(_amountFunded),
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
