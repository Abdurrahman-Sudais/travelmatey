import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class _PromoCode {
  final String code;
  final String description;
  final String discount;
  final String discountLabel;
  final String save;
  final String? minBooking;
  final String? maxDiscount;
  final String validUntil;
  final bool isFlat;

  const _PromoCode({
    required this.code,
    required this.description,
    required this.discount,
    required this.discountLabel,
    required this.save,
    this.minBooking,
    this.maxDiscount,
    required this.validUntil,
    this.isFlat = false,
  });
}

class PromoCodePage extends StatefulWidget {
  const PromoCodePage({super.key});

  @override
  State<PromoCodePage> createState() => _PromoCodePageState();
}

class _PromoCodePageState extends State<PromoCodePage> {
  final _codeCtrl = TextEditingController();
  String? _appliedCode;

  final List<_PromoCode> _promos = const [
    _PromoCode(
      code: 'WELCOME2026',
      description: 'Welcome bonus for new users',
      discount: '20%',
      discountLabel: 'OFF',
      save: 'Save 20% OFF',
      maxDiscount: 'Max discount: ₦5,000',
      validUntil: 'Valid until Mar 31, 2026',
    ),
    _PromoCode(
      code: 'NEWYEAR50',
      description: 'New Year special discount',
      discount: '50%',
      discountLabel: 'OFF',
      save: 'Save 50% OFF',
      minBooking: 'Min. booking: ₦20,000',
      maxDiscount: 'Max discount: ₦10,000',
      validUntil: 'Valid until Jan 31, 2026',
    ),
    _PromoCode(
      code: 'FLAT2K',
      description: 'Flat ₦2,000 off on all rides',
      discount: '₦2K',
      discountLabel: 'OFF',
      save: 'Save ₦2,000 OFF',
      minBooking: 'Min. booking: ₦10,000',
      validUntil: 'Valid until Feb 28, 2026',
      isFlat: true,
    ),
    _PromoCode(
      code: 'WEEKEND30',
      description: 'Weekend special - 30% off',
      discount: '30%',
      discountLabel: 'OFF',
      save: 'Save 30% OFF',
      maxDiscount: 'Max discount: ₦8,000',
      validUntil: 'Valid until Jan 26, 2026',
    ),
  ];

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _applyCode(String code) {
    setState(() => _appliedCode = code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo code $code applied!'),
        backgroundColor: kPrimaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.chevron_left, size: 22),
                          Text('Back', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Manual entry
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Enter Promo Code',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeCtrl,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1),
                                  decoration: InputDecoration(
                                    hintText: 'ENTER CODE (E.G., WELCOME2026)',
                                    hintStyle: const TextStyle(
                                        color: Colors.black38,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        letterSpacing: 0),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: kPrimaryBlue),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  if (_codeCtrl.text.isNotEmpty) {
                                    _applyCode(_codeCtrl.text.trim());
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: 72,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: kPrimaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Apply',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Available Offers',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._promos.map(_promoCard),
                    const SizedBox(height: 8),
                    // Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.info_outline,
                                  color: kAmber, size: 18),
                              SizedBox(width: 8),
                              Text('How to use promo codes',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...[
                            'Enter the code before making payment',
                            'Only one promo code can be used per booking',
                            'Check minimum amount requirements',
                            'Promo codes cannot be combined with other offers',
                          ].map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $tip',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ),
    );
  }

  Widget _promoCard(_PromoCode promo) {
    final isApplied = _appliedCode == promo.code;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isApplied
            ? Border.all(color: kPrimaryGreen, width: 1.5)
            : Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(promo.code,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1)),
                    ),
                    const SizedBox(height: 8),
                    Text(promo.description,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: kPrimaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(promo.discount,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(promo.discountLabel,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),
          _promoDetail(Icons.check_circle_outline, promo.save,
              color: kPrimaryGreen),
          if (promo.minBooking != null) ...[
            const SizedBox(height: 6),
            _promoDetail(Icons.access_time_outlined, promo.minBooking!),
          ],
          if (promo.maxDiscount != null) ...[
            const SizedBox(height: 6),
            _promoDetail(Icons.access_time_outlined, promo.maxDiscount!),
          ],
          const SizedBox(height: 6),
          _promoDetail(Icons.calendar_today_outlined, promo.validUntil,
              color: kErrorRed),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _applyCode(promo.code),
            child: Container(
              width: double.infinity,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isApplied ? null : kPrimaryGradient,
                color: isApplied ? kPrimaryGreen : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isApplied ? '✓ Applied' : 'Apply This Code',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoDetail(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.black45),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: 12, color: color ?? Colors.black54)),
      ],
    );
  }
}