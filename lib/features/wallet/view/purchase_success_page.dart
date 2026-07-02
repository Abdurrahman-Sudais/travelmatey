import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

enum PurchaseType { airtime, data }

class PurchaseSuccessPage extends StatelessWidget {
  final PurchaseType type;
  final String network;
  final String phoneNumber;
  final double amount;
  final double previousBalance;
  final String? dataBundle;
  final String? validity;

  const PurchaseSuccessPage({
    super.key,
    required this.type,
    required this.network,
    required this.phoneNumber,
    required this.amount,
    required this.previousBalance,
    this.dataBundle,
    this.validity,
  });

  double get newBalance => previousBalance - amount;

  String _fmt(double val) {
    return val.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final isData = type == PurchaseType.data;

    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 12, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Navigator.maybePop(context),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chevron_left,
                                size: 22, color: Colors.black87),
                            Text("Back",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Success icon
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: kPrimaryGreen.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: kPrimaryGreen,
                                  size: 38,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                isData
                                    ? "Data Purchase Successful!"
                                    : "Airtime Purchase Successful!",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isData
                                    ? "${dataBundle ?? '1GB'} data has been sent to $phoneNumber"
                                    : "₦${amount.toInt()} airtime has been sent to $phoneNumber",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 22),
                              // Details card
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    _row("Network", network),
                                    _divider(),
                                    _row("Phone Number", phoneNumber),
                                    if (isData) ...[
                                      _divider(),
                                      _row("Data Bundle", dataBundle ?? ''),
                                      _divider(),
                                      _row("Validity", validity ?? '30 Days'),
                                    ],
                                    _divider(),
                                    _row(
                                      isData ? "Amount Paid" : "Amount",
                                      "₦${_fmt(amount)}",
                                      valueColor: kPrimaryGreen,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Divider(
                                          height: 1, color: Color(0xFFE0E0E0)),
                                    ),
                                    _row(
                                      "New Balance",
                                      "₦${_fmt(newBalance)}",
                                      valueColor: kPrimaryBlue,
                                      valueFontSize: 16,
                                      valueBold: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              // Done button
                              GestureDetector(
                                onTap: () {
                                  // Pop back to wallet page (pop all the way)
                                  Navigator.of(context)
                                      .popUntil((r) => r.isFirst);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1565C0),
                                        kPrimaryGreen
                                      ],
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    Color? valueColor,
    double valueFontSize = 13.5,
    bool valueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
    );
  }
}