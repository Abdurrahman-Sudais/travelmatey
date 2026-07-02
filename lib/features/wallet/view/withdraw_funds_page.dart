import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/keyboard_aware_scaffold.dart';
import 'package:travelmateeee/data/repositories/wallet_repository.dart';

import 'bank_account_model.dart';
import 'bank_accounts_page.dart';

class WithdrawFundsPage extends StatefulWidget {
  final int availableBalance;

  const WithdrawFundsPage({super.key, this.availableBalance = 25000});

  @override
  State<WithdrawFundsPage> createState() => _WithdrawFundsPageState();
}

class _WithdrawFundsPageState extends State<WithdrawFundsPage> {
  final _amountCtrl = TextEditingController();
  static const int _fee = 50;
  static const int _minAmount = 1000;
  static const int _maxAmount = 500000;

  BankAccount? _selectedAccount;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAccount = BankAccountStore.instance.primary;
    BankAccountStore.instance.accounts.addListener(_onAccountsChanged);
  }

  @override
  void dispose() {
    BankAccountStore.instance.accounts.removeListener(_onAccountsChanged);
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onAccountsChanged() {
    setState(() {
      _selectedAccount ??= BankAccountStore.instance.primary;
      if (_selectedAccount != null &&
          !BankAccountStore.instance.accounts.value
              .contains(_selectedAccount)) {
        _selectedAccount = BankAccountStore.instance.primary;
      }
    });
  }

  int get _amount => int.tryParse(_amountCtrl.text.trim()) ?? 0;

  int get _total => _amount > 0 ? _amount + _fee : 0;

  bool get _canWithdraw =>
      !_isSubmitting &&
      _amount >= _minAmount &&
      _amount <= _maxAmount &&
      _amount <= widget.availableBalance &&
      _selectedAccount != null;

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  void _setQuickAmount(int amount) {
    setState(() => _amountCtrl.text = "$amount");
  }

  Future<void> _goToAddAccount() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BankAccountsPage(startInAddMode: true),
      ),
    );
    setState(() {
      _selectedAccount ??= BankAccountStore.instance.primary;
    });
  }

  void _onWithdrawTap() {
    if (!_canWithdraw) return;
    showDialog(
      context: context,
      builder: (dialogContext) => _ConfirmWithdrawalDialog(
        amount: _amount,
        fee: _fee,
        total: _total,
        account: _selectedAccount!,
        onConfirm: () {
          Navigator.pop(dialogContext);
          _performWithdrawal();
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  Future<void> _performWithdrawal() async {
    setState(() => _isSubmitting = true);
    try {
      final repo = Get.find<WalletRepository>();
      final wallet = await repo.withdrawFunds(
        amount: _amount.toDouble(),
        bankAccount: "${_selectedAccount!.bankName} - ${_selectedAccount!.accountNumber}",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Withdrawal of ₦${_formatNumber(_amount)} initiated successfully!"),
            backgroundColor: kPrimaryGreen,
          ),
        );
        setState(() => _amountCtrl.clear());
        Navigator.pop(context, wallet.balance);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to perform withdrawal: $e',
          backgroundColor: kErrorRed,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareFormScaffold(
      body: KeyboardAwareScrollBody(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _backButton(),
          const SizedBox(height: 4),
          Text(
            "Withdraw Funds",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Transfer money to your bank account",
            style: TextStyle(fontSize: 13, color: kTextSecondary),
          ),
          const SizedBox(height: 16),
          _availableBalanceCard(),
          const SizedBox(height: 16),
          _withdrawFormCard(),
          const SizedBox(height: 16),
          _withdrawalInfoCard(),
        ],
      ),
    );
  }

  Widget _backButton() {
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

  Widget _availableBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryGreen,
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
            "AVAILABLE BALANCE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₦${_formatNumber(widget.availableBalance)}",
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _withdrawFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              children: [
                TextSpan(text: "Amount to Withdraw "),
                TextSpan(text: "*", style: TextStyle(color: kErrorRed)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _amountField(),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Min: ₦1,000 • Max: ₦500,000",
                style: TextStyle(fontSize: 11.5, color: Colors.black45),
              ),
              if (_amount > 0)
                Text(
                  "Fee: ₦$_fee",
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: kAmber),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            "Quick Select",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _quickSelectRow(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  children: [
                    TextSpan(text: "Withdraw to "),
                    TextSpan(
                        text: "*", style: TextStyle(color: kErrorRed)),
                  ],
                ),
              ),
              InkWell(
                onTap: _goToAddAccount,
                child: const Text(
                  "+ Add Account",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<BankAccount>>(
            valueListenable: BankAccountStore.instance.accounts,
            builder: (context, accounts, _) {
              if (accounts.isEmpty) {
                return InkWell(
                  onTap: _goToAddAccount,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.add_card_outlined,
                            color: kPrimaryBlue, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Add a bank account to withdraw",
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryBlue),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: accounts.map(_accountSelector).toList(),
              );
            },
          ),
          if (_amount > 0) ...[
            const SizedBox(height: 18),
            _summarySection(),
          ],
          const SizedBox(height: 18),
          _withdrawButton(),
        ],
      ),
    );
  }

  Widget _amountField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _amountCtrl.text.isNotEmpty
              ? kPrimaryGreen
              : Colors.black.withValues(alpha: 0.08),
          width: _amountCtrl.text.isNotEmpty ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text("₦",
                style:
                    TextStyle(fontSize: 18, color: Colors.black45)),
          ),
          Expanded(
            child: TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "0.00",
                hintStyle: TextStyle(
                    color: Colors.black26,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickSelectRow() {
    final amounts = [5000, 10000, 20000, 50000];
    final children = <Widget>[];
    for (int i = 0; i < amounts.length; i++) {
      final a = amounts[i];
      final label = "₦${(a / 1000).round()}k";
      children.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == amounts.length - 1 ? 0 : 8),
            child: InkWell(
              onTap: () => _setQuickAmount(a),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: children);
  }

  Widget _accountSelector(BankAccount account) {
    final bool isSelected = _selectedAccount == account;
    return InkWell(
      onTap: () => setState(() => _selectedAccount = account),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? kPrimaryBlue
                : Colors.black.withValues(alpha: 0.08),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.accountName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (account.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kPrimaryGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "PRIMARY",
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${account.bankName} • ${account.accountNumber}",
                    style: const TextStyle(
                        fontSize: 12.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? kPrimaryBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? kPrimaryBlue
                      : Colors.black.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summarySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _summaryRow("Withdrawal Amount", "₦${_formatNumber(_amount)}"),
          const SizedBox(height: 8),
          _summaryRow("Transaction Fee", "₦$_fee", valueColor: kAmber),
          const Divider(height: 20, color: Color(0xFFE0E0E0)),
          _summaryRow(
            "Total Deduction",
            "₦${_formatNumber(_total)}",
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 14.5 : 13.5,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 13.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _withdrawButton() {
    final label = _amount > 0
        ? "Withdraw ₦${_formatNumber(_amount)}"
        : "Withdraw ₦0";
    return InkWell(
      onTap: _canWithdraw ? _onWithdrawTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _canWithdraw ? kPrimaryGreen : const Color(0xFFD9DCE1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _canWithdraw
              ? [
                  BoxShadow(
                    color: kPrimaryGreen.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _canWithdraw ? Colors.white : Colors.black38),
        ),
      ),
    );
  }

  Widget _withdrawalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryBlue.withValues(alpha: 0.06),
        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, size: 18, color: kPrimaryBlue),
              SizedBox(width: 8),
              Text(
                "Withdrawal Information",
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _bulletLine("Withdrawals are processed instantly"),
          _bulletLine("A flat fee of ₦50 applies per transaction"),
          _bulletLine("Funds will be credited to your bank within 24 hours"),
          _bulletLine("Ensure your account details are correct"),
        ],
      ),
    );
  }

  Widget _bulletLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "• $text",
        style: const TextStyle(
            fontSize: 12.5, color: Colors.black87, height: 1.5),
      ),
    );
  }
}

class _ConfirmWithdrawalDialog extends StatelessWidget {
  final int amount;
  final int fee;
  final int total;
  final BankAccount account;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmWithdrawalDialog({
    required this.amount,
    required this.fee,
    required this.total,
    required this.account,
    required this.onConfirm,
    required this.onCancel,
  });

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

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
                color: kAmber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: kAmber, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              "Confirm Withdrawal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Please review the details before proceeding",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Amount",
                          style: TextStyle(
                              fontSize: 13.5, color: Colors.black54)),
                      Text("₦${_formatNumber(amount)}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Fee",
                          style: TextStyle(
                              fontSize: 13.5, color: Colors.black54)),
                      Text("₦$fee",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: kAmber)),
                    ],
                  ),
                  const Divider(height: 18, color: Color(0xFFE0E0E0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold)),
                      Text("₦${_formatNumber(total)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kPrimaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TO ACCOUNT",
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: kPrimaryBlue.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 6),
                  Text(account.accountName,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(account.bankName,
                      style: const TextStyle(
                          fontSize: 12.5, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(account.accountNumber,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onCancel,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.black.withValues(alpha: 0.15)),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: onConfirm,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kPrimaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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