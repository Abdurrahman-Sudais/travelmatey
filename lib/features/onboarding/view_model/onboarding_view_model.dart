import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingViewModel extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skipToLast(int lastPageIndex) {
    pageController.animateToPage(
      lastPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void nextPage(int lastPageIndex) {
    if (currentPage.value < lastPageIndex) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
