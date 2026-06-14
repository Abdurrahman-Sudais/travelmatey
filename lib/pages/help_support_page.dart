import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/emergency_sos.dart';
import '../widgets/app_bottom_nav.dart';

class _Faq {
  final String category;
  final Color categoryColor;
  final String question;
  bool expanded;

  _Faq({
    required this.category,
    required this.categoryColor,
    required this.question,
    this.expanded = false,
  });
}

class _Guide {
  final String title;
  final String subtitle;
  final Color color;
  bool expanded;

  _Guide({
    required this.title,
    required this.subtitle,
    required this.color,
    this.expanded = false,
  });
}

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  int _tabIndex = 0; // 0: FAQs, 1: Guides, 2: Contact
  String _category = "All";

  final List<String> _categories = [
    "All",
    "Booking",
    "Payment",
    "Safety",
    "Account",
  ];

  late final List<_Faq> _faqs = [
    _Faq(
        category: "BOOKING",
        categoryColor: kPrimaryBlue,
        question: "How do I book a ride as a rider?"),
    _Faq(
        category: "BOOKING",
        categoryColor: kPrimaryBlue,
        question: "Can I cancel a booking after payment?"),
    _Faq(
        category: "BOOKING",
        categoryColor: kPrimaryBlue,
        question: "How do I know if my booking is confirmed?"),
    _Faq(
        category: "PAYMENT",
        categoryColor: kPrimaryGreen,
        question: "What is the escrow system?"),
    _Faq(
        category: "PAYMENT",
        categoryColor: kPrimaryGreen,
        question: "What payment methods are accepted?"),
    _Faq(
        category: "PAYMENT",
        categoryColor: kPrimaryGreen,
        question: "How much is the platform service charge?"),
    _Faq(
        category: "PAYMENT",
        categoryColor: kPrimaryGreen,
        question: "How do I withdraw money from my wallet?"),
    _Faq(
        category: "SAFETY",
        categoryColor: kErrorRed,
        question: "How are users verified on Travelmate?"),
    _Faq(
        category: "SAFETY",
        categoryColor: kErrorRed,
        question: "What should I do if I feel unsafe during a trip?"),
    _Faq(
        category: "SAFETY",
        categoryColor: kErrorRed,
        question: "Can I see driver/rider ratings before booking?"),
    _Faq(
        category: "ACCOUNT",
        categoryColor: kAmber,
        question: "How do I complete KYC verification?"),
    _Faq(
        category: "ACCOUNT",
        categoryColor: kAmber,
        question: "Can I switch between driver and rider roles?"),
    _Faq(
        category: "ACCOUNT",
        categoryColor: kAmber,
        question: "How do I update my profile information?"),
    _Faq(
        category: "BOOKING",
        categoryColor: kPrimaryBlue,
        question: "What happens if the driver doesn't show up?"),
    _Faq(
        category: "PAYMENT",
        categoryColor: kPrimaryGreen,
        question: "Are there any hidden charges?"),
  ];

  late final List<_Guide> _guides = [
    _Guide(
      title: "How to Post a Ride (For Drivers)",
      subtitle: "Step-by-step guide on posting your first ride",
      color: kPrimaryBlue,
    ),
    _Guide(
      title: "How to Book a Ride (For Riders)",
      subtitle: "Find and book your perfect ride",
      color: kPrimaryGreen,
    ),
    _Guide(
      title: "Understanding the Escrow System",
      subtitle: "How your payments are protected",
      color: kAmber,
    ),
    _Guide(
      title: "Safety Tips & Best Practices",
      subtitle: "Stay safe on every journey",
      color: kErrorRed,
    ),
  ];

  List<_Faq> get _filteredFaqs => _category == "All"
      ? _faqs
      : _faqs
          .where((f) =>
              f.category.toLowerCase() == _category.toLowerCase())
          .toList();

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(),
                    const SizedBox(height: 12),
                    const Text(
                      "Help & Support",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "We're here to help you",
                      style:
                          TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _tabBar(),
                    const SizedBox(height: 16),
                    if (_tabIndex == 0) ..._faqContent(),
                    if (_tabIndex == 1) ..._guideContent(),
                    if (_tabIndex == 2) ..._contactContent(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: const AppBottomNavBar(current: AppTab.profile),
            ),
          ],
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
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text("Back",
              style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabButton("FAQs", 0),
          _tabButton("Guides", 1),
          _tabButton("Contact", 2),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final bool isActive = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? kPrimaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // ── FAQs tab ───────────────────────────────────────────────────────────

  List<Widget> _faqContent() {
    return [
      _categoryFilterCard(),
      const SizedBox(height: 14),
      ..._filteredFaqs.map(_faqCard),
    ];
  }

  Widget _categoryFilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filter by Category",
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((c) {
              final bool isActive = _category == c;
              return InkWell(
                onTap: () => setState(() => _category = c),
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive
                        ? kPrimaryBlue
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color:
                          isActive ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _faqCard(_Faq faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => faq.expanded = !faq.expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                faq.categoryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: Text(
                            faq.category,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: faq.categoryColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          faq.question,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        if (faq.expanded) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Our support team has prepared a detailed "
                            "answer for this question. Please check "
                            "the in-app guide or contact support for "
                            "more information.",
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
                                height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    faq.expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Guides tab ─────────────────────────────────────────────────────────

  List<Widget> _guideContent() {
    return _guides.map(_guideCard).toList();
  }

  Widget _guideCard(_Guide guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: guide.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () => setState(() => guide.expanded = !guide.expanded),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: guide.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: guide.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide.subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: Colors.black54),
                  ),
                  if (guide.expanded) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Open this guide from the help center to view "
                      "the full walkthrough with screenshots and tips.",
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              guide.expanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact tab ────────────────────────────────────────────────────────

  List<Widget> _contactContent() {
    return [
      _emergencyCard(),
      const SizedBox(height: 16),
      _getInTouchCard(),
      const SizedBox(height: 16),
      _reportIssueCard(),
      const SizedBox(height: 16),
      _followUsCard(),
    ];
  }

  Widget _emergencyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kErrorRed, Color(0xFFFF7676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                "Emergency?",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "If you're in immediate danger during a trip, contact "
            "local emergency services first, then report to us.",
            style: TextStyle(
                fontSize: 13, color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Nigeria Emergency: 112 or 199",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getInTouchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Get in Touch",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.email_outlined,
            iconColor: kPrimaryBlue,
            title: "Email Support",
            value: "info@cgtechinvestment.ng",
            subtitle: "Response within 24 hours",
            valueColor: kPrimaryBlue,
          ),
          const Divider(height: 24, color: Color(0xFFF2F2F2)),
          _contactRow(
            icon: Icons.call_outlined,
            iconColor: kPrimaryGreen,
            title: "Phone Support",
            value: "08053300737",
            subtitle: "Mon - Fri: 8AM - 6PM WAT",
            valueColor: kPrimaryBlue,
          ),
          const Divider(height: 24, color: Color(0xFFF2F2F2)),
          _contactRow(
            icon: Icons.location_on_outlined,
            iconColor: kAmber,
            title: "Office Address",
            value: "No. 19, Beirut Road, Kano, Nigeria",
            subtitle: "Visit us during business hours",
            valueColor: kPrimaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.black87)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11.5, color: Colors.black45)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reportIssueCard() {
    final items = [
      ("⚠️", "Report Safety Concern"),
      ("💰", "Report Payment Issue"),
      ("👤", "Report User Behavior"),
      ("🐛", "Report Technical Bug"),
      ("🔧", "Run System Diagnostics"),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Report an Issue",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...List.generate(items.length, (i) {
            final (emoji, label) = items[i];
            return InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: i == items.length - 1
                      ? null
                      : const Border(
                          bottom: BorderSide(
                              color: Color(0xFFF5F5F5))),
                ),
                child: Row(
                  children: [
                    Text(emoji,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600)),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: Colors.black38),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _followUsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Follow Us",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            "Stay updated with the latest news and features",
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _socialIcon(Icons.facebook),
              const SizedBox(width: 12),
              _socialIcon(Icons.alternate_email),
              const SizedBox(width: 12),
              _socialIcon(Icons.camera_alt_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}