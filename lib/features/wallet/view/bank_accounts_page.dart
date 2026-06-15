import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

import 'bank_account_model.dart';

class BankAccountsPage extends StatefulWidget {
  /// If true, shows the "Add Bank Account" form immediately
  /// (used when navigating from the empty "No Bank Account" state).
  final bool startInAddMode;

  const BankAccountsPage({super.key, this.startInAddMode = false});

  @override
  State<BankAccountsPage> createState() => _BankAccountsPageState();
}

class _BankAccountsPageState extends State<BankAccountsPage> {
  late bool _showAddForm;

  String? _selectedBank;
  final _accountNumberCtrl = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _verifiedName;

  @override
  void initState() {
    super.initState();
    _showAddForm =
        widget.startInAddMode ||
        BankAccountStore.instance.accounts.value.isEmpty;
  }

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  bool get _canVerify =>
      _selectedBank != null && _accountNumberCtrl.text.trim().length == 10;

  bool get _canAddAccount => _isVerified;

  Future<void> _verify() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      _isVerifying = false;
      _isVerified = true;
      // Mock resolved account name
      _verifiedName = "JOHN DOE ADEBAYO";
    });
  }

  void _addAccount() {
    final account = BankAccount(
      accountName: _verifiedName ?? "JOHN DOE ADEBAYO",
      bankName: _selectedBank!,
      accountNumber: _accountNumberCtrl.text.trim(),
    );
    BankAccountStore.instance.add(account);
    setState(() {
      _showAddForm = false;
      _selectedBank = null;
      _accountNumberCtrl.clear();
      _isVerified = false;
      _verifiedName = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bank account added successfully!"),
        backgroundColor: kPrimaryGreen,
      ),
    );
  }

  void _confirmDelete(BankAccount account) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Remove Account",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Remove ${account.bankName} •••• "
            "${account.accountNumber.substring(account.accountNumber.length - 4)} "
            "from your saved accounts?",
            style: const TextStyle(fontSize: 13.5, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  BankAccountStore.instance.remove(account);
                  if (BankAccountStore.instance.accounts.value.isEmpty) {
                    _showAddForm = true;
                  }
                });
              },
              child: const Text(
                "Remove",
                style: TextStyle(color: kErrorRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: Stack(
          children: [
            SafeArea(
              child: ValueListenableBuilder<List<BankAccount>>(
                valueListenable: BankAccountStore.instance.accounts,
                builder: (context, accounts, _) {
                  if (accounts.isEmpty && !_showAddForm) {
                    return _noBankAccountState();
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _backButton(),
                        const SizedBox(height: 8),
                        const Text(
                          "Bank Accounts",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Manage your withdrawal bank accounts",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 18),
                        if (_showAddForm)
                          _addAccountCard()
                        else
                          _savedAccountsSection(accounts),
                        const SizedBox(height: 16),
                        _importantInfoCard(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: const AppBottomNavBar(current: AppTab.wallet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        if (_showAddForm &&
            BankAccountStore.instance.accounts.value.isNotEmpty) {
          setState(() => _showAddForm = false);
        } else {
          Navigator.maybePop(context);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _noBankAccountState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [_backButton()]),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      size: 46,
                      color: kPrimaryBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "No Bank Account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "You need to add a bank account before you can "
                    "withdraw funds. Add your account details to get "
                    "started.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  InkWell(
                    onTap: () => setState(() => _showAddForm = true),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryGreen.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Add Bank Account",
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
    );
  }

  Widget _addAccountCard() {
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
          const Text(
            "Add Bank Account",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              children: [
                TextSpan(text: "Select Bank "),
                TextSpan(
                  text: "*",
                  style: TextStyle(color: kErrorRed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _bankDropdown(),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              children: [
                TextSpan(text: "Account Number "),
                TextSpan(
                  text: "*",
                  style: TextStyle(color: kErrorRed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _accountNumberCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  onChanged: (_) {
                    setState(() {
                      _isVerified = false;
                      _verifiedName = null;
                    });
                  },
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "0123456789",
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kPrimaryBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: (_canVerify && !_isVerifying) ? _verify : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _canVerify ? kPrimaryBlue : const Color(0xFFD9DCE1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Verify",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _canVerify ? Colors.white : Colors.black38,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Enter your 10-digit account number",
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          if (_isVerified) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryGreen.withOpacity(0.08),
                border: Border.all(color: kPrimaryGreen.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle, size: 16, color: kPrimaryGreen),
                      SizedBox(width: 6),
                      Text(
                        "Account Verified",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _verifiedName ?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          InkWell(
            onTap: _canAddAccount ? _addAccount : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: _canAddAccount ? kPrimaryGradient : null,
                color: _canAddAccount ? null : const Color(0xFFD9DCE1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Add Account",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _canAddAccount ? Colors.white : Colors.black38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankDropdown() {
    return InkWell(
      onTap: () => _showBankPicker(),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedBank != null
                ? kPrimaryBlue
                : Colors.black.withOpacity(0.08),
            width: _selectedBank != null ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedBank ?? "Choose your bank",
              style: TextStyle(
                fontSize: 14,
                fontWeight: _selectedBank != null
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: _selectedBank != null ? Colors.black87 : Colors.black38,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void _showBankPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: kNigerianBanks
                .map(
                  (b) => ListTile(
                    title: Text(b),
                    onTap: () {
                      setState(() {
                        _selectedBank = b;
                        _isVerified = false;
                        _verifiedName = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _savedAccountsSection(List<BankAccount> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Saved Accounts (${accounts.length})",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...accounts.map(_accountCard),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _showAddForm = true),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryGreen.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "Add New Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _accountCard(BankAccount account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        account.accountName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (account.isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "PRIMARY",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: kPrimaryGreen,
                      ),
                    ],
                  ],
                ),
              ),
              InkWell(
                onTap: () => _confirmDelete(account),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, color: kErrorRed, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            account.bankName,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            account.accountNumber,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
          if (!account.isPrimary) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () =>
                  setState(() => BankAccountStore.instance.setPrimary(account)),
              child: const Text(
                "Set as Primary",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _importantInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAmber.withOpacity(0.12),
        border: Border.all(color: kAmber.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, size: 18, color: kAmber),
              SizedBox(width: 8),
              Text(
                "Important Information",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _bulletLine("Account must be in your registered name"),
          _bulletLine("Withdrawals can only be made to verified accounts"),
          _bulletLine("Set a primary account for faster withdrawals"),
          _bulletLine("All transactions are secured and encrypted"),
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
          fontSize: 12.5,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}
