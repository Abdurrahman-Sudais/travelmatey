import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';

enum _EarningsPeriod { week, month, year }

enum _TxStatus { completed, held, pending }

class _Transaction {
  final String title;
  final String date;
  final _TxStatus status;
  final String amount;
  final bool isCredit;

  const _Transaction({
    required this.title,
    required this.date,
    required this.status,
    required this.amount,
    required this.isCredit,
  });
}

/// Wallet & Earnings page.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  _EarningsPeriod _period = _EarningsPeriod.week;

  static const Map<_EarningsPeriod, _EarningsData> _earningsByPeriod = {
    _EarningsPeriod.week: _EarningsData(
      amount: "₦120,000",
      changeLabel: "+8.2% vs last week",
    ),
    _EarningsPeriod.month: _EarningsData(
      amount: "₦450,000",
      changeLabel: "+12.4% vs last month",
    ),
    _EarningsPeriod.year: _EarningsData(
      amount: "₦4,200,000",
      changeLabel: "+21.6% vs last year",
    ),
  };

  static const _transactions = [
    _Transaction(
      title: "Wallet funding via card",
      date: "Jun 12, 2026",
      status: _TxStatus.completed,
      amount: "+₦10,000",
      isCredit: true,
    ),
    _Transaction(
      title: "Ride payment - Lagos to Ibadan",
      date: "Jun 11, 2026",
      status: _TxStatus.held,
      amount: "₦5,000",
      isCredit: false,
    ),
    _Transaction(
      title: "Ride earnings",
      date: "Jun 10, 2026",
      status: _TxStatus.completed,
      amount: "+₦4,500",
      isCredit: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(context),
                  const SizedBox(height: 12),
                  const Text(
                    "Wallet & Earnings",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Manage your funds",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 18),
                  _balanceCard(),
                  const SizedBox(height: 14),
                  _withdrawButton(),
                  const SizedBox(height: 20),
                  _sectionTitle("Quick Services"),
                  const SizedBox(height: 10),
                  _quickServicesRow(),
                  const SizedBox(height: 14),
                  _transactionsAndEscrowRow(),
                  const SizedBox(height: 20),
                  _earningsOverviewCard(),
                  const SizedBox(height: 20),
                  _sectionTitle("Recent Transactions"),
                  const SizedBox(height: 10),
                  ..._transactions.map(_transactionCard),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: const AppBottomNavBar(current: AppTab.wallet),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text("Back",
              style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.5));
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOTAL BALANCE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 1,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.credit_card,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "₦25,000",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _balanceSubStat(
                  label: "AVAILABLE",
                  value: "₦25,000",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _balanceSubStat(
                  label: "PENDING",
                  value: "₦0",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _balanceSubStat(
                  label: "HELD",
                  value: "₦0",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceSubStat({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _withdrawButton() {
    return InkWell(
      onTap: () {
        // TODO: navigate to withdraw funds flow
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, color: kPrimaryGreen, size: 20),
            SizedBox(width: 8),
            Text(
              "Withdraw Funds",
              style: TextStyle(
                color: kPrimaryGreen,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickServicesRow() {
    return Row(
      children: [
        Expanded(
          child: _quickServiceItem(
            icon: Icons.phone_android,
            bgColor: kPrimaryBlue.withOpacity(0.1),
            iconColor: kPrimaryBlue,
            label: "Airtime",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickServiceItem(
            icon: Icons.wifi,
            bgColor: kPrimaryGreen.withOpacity(0.1),
            iconColor: kPrimaryGreen,
            label: "Data",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickServiceItem(
            icon: Icons.description_outlined,
            bgColor: kAmber.withOpacity(0.12),
            iconColor: kAmber,
            label: "Bills",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickServiceItem(
            icon: Icons.add,
            bgColor: const Color(0xFFEC4899).withOpacity(0.1),
            iconColor: const Color(0xFFEC4899),
            label: "Fund",
          ),
        ),
      ],
    );
  }

  Widget _quickServiceItem({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String label,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _transactionsAndEscrowRow() {
    return Row(
      children: [
        Expanded(
          child: _navCard(
            icon: Icons.receipt_long_outlined,
            iconBg: kPrimaryBlue.withOpacity(0.1),
            iconColor: kPrimaryBlue,
            title: "Transactions",
            subtitle: "Manage & Export",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _navCard(
            icon: Icons.lock_outline,
            iconBg: kAmber.withOpacity(0.12),
            iconColor: kAmber,
            title: "Escrow",
            subtitle: "Held Funds",
          ),
        ),
      ],
    );
  }

  Widget _navCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _earningsOverviewCard() {
    final data = _earningsByPeriod[_period]!;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Earnings Overview",
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              _periodToggle(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.amount,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up,
                    size: 14, color: kPrimaryGreen),
                const SizedBox(width: 4),
                Text(
                  data.changeLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          _periodTab("Week", _EarningsPeriod.week),
          _periodTab("Month", _EarningsPeriod.month),
          _periodTab("Year", _EarningsPeriod.year),
        ],
      ),
    );
  }

  Widget _periodTab(String label, _EarningsPeriod period) {
    final bool isActive = _period == period;
    return InkWell(
      onTap: () => setState(() => _period = period),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isActive ? kPrimaryGreen : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _transactionCard(_Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.access_time,
                size: 18, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      tx.date,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black38),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(tx.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            tx.amount,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: tx.isCredit ? kPrimaryGreen : kErrorRed,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
        ],
      ),
    );
  }

  Widget _statusBadge(_TxStatus status) {
    String label;
    Color color;
    switch (status) {
      case _TxStatus.completed:
        label = "COMPLETED";
        color = kPrimaryGreen;
        break;
      case _TxStatus.held:
        label = "HELD";
        color = kErrorRed;
        break;
      case _TxStatus.pending:
        label = "PENDING";
        color = kAmber;
        break;
    }
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _EarningsData {
  final String amount;
  final String changeLabel;

  const _EarningsData({required this.amount, required this.changeLabel});
}