import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travelmateeee/base/base_view.dart';
import 'package:travelmateeee/routes.dart';
import 'package:travelmateeee/screens/into/onboarding/onboarding_view_model.dart';
import 'package:travelmateeee/utils/color_utils.dart';
import 'package:travelmateeee/utils/extensions.dart';
import 'package:travelmateeee/utils/font_weight_utils.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<OnBoardingViewModel>(
      onInit: (OnBoardingViewModel viewModel) async {},
      onResumed: (OnBoardingViewModel viewModel) async {},
      onPaused: (OnBoardingViewModel viewModel) {},
      onInternetConnected: (OnBoardingViewModel viewModel) {},
      onInternetDisconnected: (OnBoardingViewModel viewModel) {},
      onDispose: (OnBoardingViewModel viewModel) {},
      view: _buildView,
    );
  }

  Widget _buildView(BuildContext context, OnBoardingViewModel viewModel) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildConcentricCirclesBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: viewModel.pageController,
                    children: [
                      _buildOnboardingPage(
                        context,
                        title: 'Trips Made Easy',
                        description:
                            'Join the carpooling community and save time and money on your daily commute',
                        illustration: _buildLogoIllustration(),
                      ),
                      _buildOnboardingPage(
                        context,
                        title: 'Save Environment',
                        description:
                            'Reduce your carbon footprint and help to reduce traffic congestion',
                        illustration: _buildMapPinIllustration(),
                      ),
                      _buildOnboardingPage(
                        context,
                        title: 'Stress Free Commute',
                        description:
                            'Get to your destination without the hassle of driving or public transport',
                        illustration: _buildLogoIllustration(),
                        isFinal: true,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40.h),
                  child: SmoothPageIndicator(
                    controller: viewModel.pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.white.withOpacity(0.3),
                      activeDotColor: Colors.white,
                      dotWidth: 8.w,
                      dotHeight: 8.h,
                      expansionFactor: 3,
                      spacing: 6.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConcentricCirclesBackground() {
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
          color: Colors.white.withOpacity(0.05),
          width: 1.5.w,
        ),
      ),
    );
  }

  Widget _buildLogoIllustration() {
    return Container(
      width: 140.w,
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
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
          // Outer pulse ring
          Container(
            width: 130.w,
            height: 130.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
          // Black map pin container
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
                // Pin pointer triangle
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

  Widget _buildOnboardingPage(
    BuildContext context, {
    required String title,
    required String description,
    required Widget illustration,
    bool isFinal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration,
          50.sbH,
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeightUtils.Bold,
              fontSize: 28.sp,
              color: Colors.white,
            ),
          ),
          16.sbH,
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeightUtils.Regular,
              color: Colors.white.withOpacity(0.85),
              fontSize: 16.sp,
              height: 1.4,
            ),
          ),
          if (isFinal) ...[
            50.sbH,
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
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
