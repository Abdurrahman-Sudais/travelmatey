import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/keyboard_aware_scaffold.dart';
import 'package:travelmateeee/data/repositories/wallet_repository.dart';

/// Bank Transfer page.
class BankTransferPage extends StatefulWidget {
  final double currentBalance;

  const BankTransferPage({super.key, required this.currentBalance});

  @override
  State<BankTransferPage> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage> {
  late double _balance;
  final TextEditingController _transferAmountController =
      TextEditingController();

  static const String _bankName = "Wema Bank";
  static const String _accountNumber = "7854123690";
  static const String _accountName = "Travelmate Wallet - John Doe";

  @override
  void initState() {
    super.initState();
    _balance = widget.currentBalance;
  }

  @override
  void dispose() {
    _transferAmountController.dispose();
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

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$label copied"), duration: const Duration(seconds: 1)),
    );
  }

  double get _transferAmount =>
      double.tryParse(_transferAmountController.text) ?? 0;

  bool get _canConfirm => _transferAmount >= 100;

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => _ConfirmTransferDialog(
        amount: _transferAmount,
        formatNaira: _formatNaira,
        onConfirm: () async {
          Navigator.pop(context); // close dialog
          try {
            final repo = Get.find<WalletRepository>();
            final wallet = await repo.fundWallet(
              amount: _transferAmount,
              method: 'bank_transfer',
            );
            if (!mounted) return;
            setState(() {
              _balance = wallet.balance;
              _transferAmountController.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Transfer confirmed. Wallet credited!"),
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to confirm transfer: $e',
              backgroundColor: kErrorRed,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareFormScaffold(
      body: KeyboardAwareScrollBody(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _backButton(),
          const SizedBox(height: 8),
          Text(
            "Bank Transfer",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Transfer funds from your bank app",
            style: TextStyle(fontSize: 13, color: kTextSecondary),
          ),
          const SizedBox(height: 18),
          _balanceCard(),
          const SizedBox(height: 16),
          _step1Card(),
          const SizedBox(height: 16),
          _step2Card(),
          const SizedBox(height: 16),
          _step3Card(),
          const SizedBox(height: 16),
          _importantInfoCard(),
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

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF12A150), kPrimaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryGreen.withValues(alpha: 0.25),
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

  Widget _stepHeader(String number, String title, Color bg, Color fg) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Text(
            number,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fg),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _step1Card() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            "1",
            "Copy Account Details",
            kPrimaryBlue.withValues(alpha: 0.12),
            kPrimaryBlue,
          ),
          const SizedBox(height: 14),
          const Text(
            "Use the account details below to make a transfer from your bank app or internet banking.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          _detailRow("BANK NAME", _bankName),
          const SizedBox(height: 10),
          _detailRow("ACCOUNT NUMBER", _accountNumber, valueColor: kPrimaryBlue),
          const SizedBox(height: 10),
          _detailRow("ACCOUNT NAME", _accountName),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _copyToClipboard(value, label),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kPrimaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    "Copy",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step2Card() {
    const steps = [
      "Open your bank mobile app or internet banking",
      "Select \"Transfer\" or \"Send Money\"",
      "Enter the account details provided above",
      "Enter the amount you want to fund",
      "Complete the transfer",
    ];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            "2",
            "Make the Transfer",
            kPrimaryGreen.withValues(alpha: 0.12),
            kPrimaryGreen,
          ),
          const SizedBox(height: 14),
          const Text(
            "Open your bank app and transfer any amount to the account above. Your wallet will be credited automatically within 5-10 minutes.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: kPrimaryBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: kPrimaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step3Card() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            "3",
            "Confirm Transfer (Optional)",
            kAmber.withValues(alpha: 0.15),
            kAmber,
          ),
          const SizedBox(height: 14),
          const Text(
            "Already completed the transfer? Enter the amount to speed up verification.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Text(
            "Transfer Amount",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _transferAmountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixText: "₦  ",
              hintText: "0.00",
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
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _canConfirm ? _showConfirmDialog : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _canConfirm ? kPrimaryGreen : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "I've Completed Transfer",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _importantInfoCard() {
    const items = [
      "Transfers are verified automatically",
      "Funds reflect in your wallet within 5-10 minutes",
      "This account is unique to your wallet",
      "Minimum transfer amount is ₦100",
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: kPrimaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                "Important Information",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "•  ",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmTransferDialog extends StatelessWidget {
  final double amount;
  final String Function(double) formatNaira;
  final VoidCallback onConfirm;

  const _ConfirmTransferDialog({
    required this.amount,
    required this.formatNaira,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              "Confirm Transfer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Did you complete the transfer?",
              style: TextStyle(fontSize: 13.5, color: Colors.black54),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transfer Amount",
                    style: TextStyle(fontSize: 13.5, color: Colors.black54),
                  ),
                  Text(
                    formatNaira(amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kErrorRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kAmber.withValues(alpha: 0.3)),
              ),
              child: const Text(
                "We'll verify your transfer and credit your wallet within 5-10 minutes. You'll receive a notification once complete.",
                style: TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: onConfirm,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kPrimaryGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        "Yes, I Did",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}