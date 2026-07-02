import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class MakePaymentPage extends StatefulWidget {
  final String from;
  final String to;

  const MakePaymentPage({
    super.key,
    required this.from,
    required this.to,
  });

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  String _amountOption = "Full Payment";
  String _paymentMethod = "Wallet";
  late final TextEditingController _remarksController;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _remarksController =
        TextEditingController(text: "${widget.from} to ${widget.to}");
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _proceed() {
    setState(() => _redirecting = true);
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
                    _topBar(),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "You're about to pay for your ${widget.from} to "
                        "${widget.to} trip. The payment will be held by "
                        "the platform until you confirm the trip is "
                        "completed.",
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "Select Amount to Pay",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _dropdownField(
                      value: _amountOption,
                      items: const ["Full Payment", "50% Deposit"],
                      onChanged: (v) => setState(() => _amountOption = v!),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Select Payment Method",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _dropdownField(
                      value: _paymentMethod,
                      items: const ["Wallet", "Card", "Bank Transfer"],
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Remarks",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _remarksController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: kPrimaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _proceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Proceed",
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_redirecting) ...[
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          "Redirecting to Wallet",
                          style: TextStyle(fontSize: 13, color: Colors.black38),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chevron_left, size: 22, color: Colors.black87),
              Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, size: 24, color: Colors.black87),
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kErrorRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}