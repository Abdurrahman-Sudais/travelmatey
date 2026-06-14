import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/emergency_sos.dart';
import '../widgets/app_bottom_nav.dart';

class _PdfItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  const _PdfItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}

class PdfExportManagerPage extends StatelessWidget {
  const PdfExportManagerPage({super.key});

  static const List<_PdfItem> _pdfs = [
    _PdfItem(
      icon: Icons.map_outlined,
      iconColor: kPrimaryBlue,
      iconBg: Color(0xFFE7F1FB),
      title: "1. Application Sitemap",
      description:
          "Complete navigation structure organized by categories "
          "with detailed page descriptions and route information.",
    ),
    _PdfItem(
      icon: Icons.bolt,
      iconColor: kPrimaryGreen,
      iconBg: Color(0xFFE8F5E9),
      title: "2. Page Links & Navigation Flow",
      description:
          "User journey flows showing the navigation path through "
          "different use cases, plus an alphabetical page index.",
    ),
    _PdfItem(
      icon: Icons.auto_awesome,
      iconColor: kErrorRed,
      iconBg: Color(0xFFFFEAEA),
      title: "3. Features Overview",
      description:
          "Comprehensive documentation of all features, "
          "capabilities, and technology stack used in the "
          "application.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _exportInfoCard(),
                          const SizedBox(height: 16),
                          _statsRow(),
                          const SizedBox(height: 20),
                          const Text(
                            "Available PDFs",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ..._pdfs.map(_pdfCard),
                          const SizedBox(height: 16),
                          _generateAllButton(),
                        ],
                      ),
                    ),
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

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.only(top: 4, right: 4),
            child: Icon(Icons.chevron_left,
                size: 26, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "PDF Export Manager",
              style: TextStyle(
                  fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              "Generate presentation PDFs",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _exportInfoCard() {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimaryBlue, kPrimaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Export Application Documentation",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Generate comprehensive PDF documentation of "
                  "the Travelmate application including sitemap, "
                  "page links, navigation flows, and features "
                  "overview. Perfect for presentations and "
                  "stakeholder reviews.",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
              value: "64",
              label: "Total Pages",
              color: kPrimaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
              value: "11",
              label: "Categories",
              color: kPrimaryGreen),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
              value: "3", label: "PDF Files", color: kErrorRed),
        ),
      ],
    );
  }

  Widget _statCard(
      {required String value,
      required String label,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      alignment: Alignment.center,
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
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12.5, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _pdfCard(_PdfItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                      height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _generateAllButton() {
    return InkWell(
      onTap: () {
        // TODO: generate and download all PDFs
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: kPrimaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGreen.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              "Generate All PDFs",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}