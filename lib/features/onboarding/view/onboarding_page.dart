import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travelmateeee/app/routes.dart';
import 'package:travelmateeee/core/utils/color_utils.dart';
import 'package:travelmateeee/core/utils/extensions.dart';
import 'package:travelmateeee/core/utils/font_weight_utils.dart';
import 'package:travelmateeee/features/onboarding/view_model/onboarding_view_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  static const int _pageCount = 3;

  late final AnimationController _enterCtrl;
  late final Animation<double> _illustrationFade;
  late final Animation<double> _illustrationScale;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _descFade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _illustrationFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _illustrationScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _enterCtrl,
            curve: const Interval(0.3, 0.75, curve: Curves.easeOut),
          ),
        );
    _titleFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.3, 0.75, curve: Curves.easeOut),
    );
    _descFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _enterCtrl.forward();
  }

  /// Re-run the entrance animation each time the user swipes to a new page.
  void _onPageChanged(int index) {
    _enterCtrl.forward(from: 0);
    Get.find<OnBoardingViewModel>().onPageChanged(index);
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Get.find — the binding called Get.put before this page builds.
    final viewModel = Get.find<OnBoardingViewModel>();

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // ── Top bar: Skip ────────────────────────────────────────────
                _buildTopBar(viewModel),

                // ── Pages ────────────────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: viewModel.pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: _onPageChanged,
                    children: [
                      _buildPage(
                        title: 'Trips Made Easy',
                        description:
                            'Join the carpooling community and save time and money on your daily commute',
                        illustration: _buildLogoIllustration(),
                      ),
                      _buildPage(
                        title: 'Save Environment',
                        description:
                            'Reduce your carbon footprint and help to reduce traffic congestion',
                        illustration: _buildMapPinIllustration(),
                      ),
                      _buildPage(
                        title: 'Stress Free Commute',
                        description:
                            'Get to your destination without the hassle of driving or public transport',
                        illustration: _buildLogoIllustration(),
                      ),
                    ],
                  ),
                ),

                // ── Dot indicator ─────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: SmoothPageIndicator(
                    controller: viewModel.pageController,
                    count: _pageCount,
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.white.withValues(alpha: 0.3),
                      activeDotColor: Colors.white,
                      dotWidth: 8.w,
                      dotHeight: 8.h,
                      expansionFactor: 3,
                      spacing: 6.w,
                    ),
                  ),
                ),

                // ── Bottom buttons ────────────────────────────────────────────
                Obx(() => _buildBottomButtons(viewModel)),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar(OnBoardingViewModel vm) {
    return Obx(() {
      final isLast = vm.currentPage.value == _pageCount - 1;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo / brand
            Text(
              'TravelMate',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16.sp,
                fontWeight: FontWeightUtils.SemiBold,
                letterSpacing: 0.5,
              ),
            ),
            // Skip (hidden on last page)
            AnimatedOpacity(
              opacity: isLast ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: GestureDetector(
                onTap: () => vm.skipToLast(_pageCount - 1),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeightUtils.Medium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Bottom buttons ─────────────────────────────────────────────────────────

  Widget _buildBottomButtons(OnBoardingViewModel vm) {
    final isLast = vm.currentPage.value == _pageCount - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: isLast
          ? Column(
              children: [
                // SIGN UP
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorUtils.ButtonBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Get.toNamed(RouteConstants.SIGNUP),
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeightUtils.LightBold,
                      ),
                    ),
                  ),
                ),
                16.sbH,
                // SIGN IN
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: ColorUtils.ButtonBlueColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => Get.toNamed(RouteConstants.SIGNIN),
                    child: Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: ColorUtils.ButtonBlueColor,
                        fontWeight: FontWeightUtils.LightBold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF007A22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () => vm.nextPage(_pageCount - 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeightUtils.LightBold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Page content ───────────────────────────────────────────────────────────

  Widget _buildPage({
    required String title,
    required String description,
    required Widget illustration,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration: fade + scale entrance
              FadeTransition(
                opacity: _illustrationFade,
                child: ScaleTransition(
                  scale: _illustrationScale,
                  child: illustration,
                ),
              ),
              50.sbH,
              // Title: fade + slide up
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeightUtils.Bold,
                      fontSize: 28.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              16.sbH,
              // Description: fade in last
              FadeTransition(
                opacity: _descFade,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeightUtils.Regular,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16.sp,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Illustrations ──────────────────────────────────────────────────────────

  Widget _buildLogoIllustration() {
    return Container(
      width: 140.w,
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 100.w,
          height: 100.h,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.car_copy,
            size: 45.sp,
            color: const Color(0xFF007A22),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPinIllustration() {
    return SizedBox(
      width: 140.w,
      height: 140.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130.w,
            height: 130.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            bottom: 25.h,
            child: Column(
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.car_copy,
                        size: 24.sp,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  size: Size(16.w, 10.h),
                  painter: _TrianglePainter(Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ─────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF007A22),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCircle(650),
          _buildCircle(500),
          _buildCircle(350),
          _buildCircle(200),
        ],
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.5.w,
        ),
      ),
    );
  }
}

// ─── Triangle painter for map-pin ─────────────────────────────────────────────

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
