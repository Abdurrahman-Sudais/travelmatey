import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
                        illustration: _buildLogoIllustration(),
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
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16.sp,
                fontWeight: FontWeightUtils.semiBold,
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
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeightUtils.medium,
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
                      backgroundColor: ColorUtils.buttonBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Get.toNamed(RouteConstants.SIGNUP),
                    child: Text(
                      'SIGN UP',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeightUtils.lightBold,
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
                        color: ColorUtils.buttonBlueColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => Get.toNamed(RouteConstants.SIGNIN),
                    child: Text(
                      'SIGN IN',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: ColorUtils.buttonBlueColor,
                        fontWeight: FontWeightUtils.lightBold,
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
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeightUtils.lightBold,
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
              // Main brand title
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    'TravelMate',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeightUtils.bold,
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              6.sbH,
              // Tagline
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    'Your journey, our priority',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeightUtils.semiBold,
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              6.sbH,
              // Page-specific title: fade + slide up
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeightUtils.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 22.sp,
                      color: const Color(0xFFFFA726),
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
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeightUtils.regular,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14.sp,
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
    return SizedBox(
      width: 100.w,
      height: 220.h,
      child: _AnimatedLogo(assetPath: 'lib/assets/logo.png'),
    );
  }
  // ── Background ─────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/onboarding_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


// ─── Animated logo: rotate 360° -> bounce up & back -> pause -> repeat ───────

class _AnimatedLogo extends StatefulWidget {
  final String assetPath;
  const _AnimatedLogo({required this.assetPath});

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Segment timings (in ms) inside one full cycle
  static const int _rotateMs = 900;
  static const int _bounceUpMs = 180;
  static const int _bounceDownMs = 220;
  static const int _pauseMs = 1200;
  static const int _totalMs =
      _rotateMs + _bounceUpMs + _bounceDownMs + _pauseMs;

  late final Animation<double> _rotation;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: _totalMs),
      vsync: this,
    )..repeat();

    final rotateEnd = _rotateMs / _totalMs;
    final bounceUpEnd = (_rotateMs + _bounceUpMs) / _totalMs;
    final bounceDownEnd = (_rotateMs + _bounceUpMs + _bounceDownMs) / _totalMs;

    // 0 -> rotateEnd: full 360° spin. Stays at 1.0 (360°) afterwards.
    _rotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: rotateEnd * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: (1 - rotateEnd) * 100,
      ),
    ]).animate(_controller);

    // 0 through rotateEnd: no bounce. Then up, then back down, then hold at 0.
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: rotateEnd * 100),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -16.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: (bounceUpEnd - rotateEnd) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -16.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: (bounceDownEnd - bounceUpEnd) * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: (1 - bounceDownEnd) * 100,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Perspective matrix so the Y-axis rotation actually looks 3D
        // instead of just squashing flat.
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0015) // perspective
          ..rotateY(_rotation.value * 6.28318530718); // 2 * pi around Y-axis

        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.assetPath),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
