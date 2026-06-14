import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingViewModel extends GetxController {
  final PageController pageController = PageController();

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
