import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'card_funding_page.dart';
import 'bank_transfer_page.dart';

/// Fund Your Wallet page - choose funding method.
class FundWalletPage extends StatefulWidget {
  final double currentBalance;

  const FundWalletPage({super.key, required this.currentBalance});

  @override
  State<FundWalletPage> createState() => _FundWalletPageState();
}

class _FundWalletPageState extends State<FundWalletPage> {
  late double _balance;

  @override
  void initState() {
    super.initState();
    _balance = widget.currentBalance;
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

  Future<void> _openCardFunding() async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => CardFundingPage(currentBalance: _balance),
      ),
    );
    if (result != null) {
      setState(() => _balance = result);
    }
  }

  Future<void> _openBankTransfer() async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => BankTransferPage(currentBalance: _balance),
      ),
    );
    if (result != null) {
      setState(() => _balance = result);
    }
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
                    _backButton(),
                    const SizedBox(height: 8),
                    const Text(
                      "Fund Your Wallet",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Choose your preferred funding method",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    _balanceCard(),
                    const SizedBox(height: 20),
                    const Text(
                      "Select Funding Method",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _methodTile(
                      icon: Icons.credit_card,
                      iconBg: kPrimaryBlue.withOpacity(0.1),
                      iconColor: kPrimaryBlue,
                      title: "Fund with Card",
                      subtitle: "Instant funding via debit/credit card",
                      onTap: _openCardFunding,
                    ),
                    const SizedBox(height: 12),
                    _methodTile(
                      icon: Icons.swap_horiz,
                      iconBg: kPrimaryGreen.withOpacity(0.1),
                      iconColor: kPrimaryGreen,
                      title: "Bank Transfer",
                      subtitle: "Transfer from your bank app",
                      onTap: _openBankTransfer,
                    ),
                    const SizedBox(height: 18),
                    _fundingInfoCard(),
                  ],
                ),
              ),
        ),
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
            color: kPrimaryGreen.withOpacity(0.25),
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
              color: Colors.white.withOpacity(0.85),
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

  Widget _methodTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _fundingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAmber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAmber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: kAmber, size: 18),
              SizedBox(width: 8),
              Text(
                "Funding Information",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._infoBullets(),
        ],
      ),
    );
  }

  List<Widget> _infoBullets() {
    const items = [
      "Card payments are processed instantly",
      "Bank transfers reflect within 5-10 minutes",
      "No fees for wallet funding",
      "Minimum funding amount is ₦100",
    ];
    return items
        .map(
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
        )
        .toList();
  }
}