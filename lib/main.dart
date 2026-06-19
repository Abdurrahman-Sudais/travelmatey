import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/app/routes.dart';
import 'package:travelmateeee/core/di/service_locator.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';

void main() {
  ServiceLocator.init();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const TravelMateApp(),
    ),
  );
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  static ThemeData _lightTheme() {
    return ThemeData(
      fontFamily: 'Poppins',
      brightness: Brightness.light,
      scaffoldBackgroundColor: kLightBackground,
      colorScheme: const ColorScheme.light(
        primary: kPrimaryBlue,
        secondary: kPrimaryGreen,
        surface: kLightSurface,
        onSurface: kLightTextPrimary,
        onSurfaceVariant: kLightTextSecondary,
      ),
      cardColor: kLightSurface,
      dividerColor: kLightDivider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kLightInputFill,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kLightBackground,
        foregroundColor: kLightTextPrimary,
        elevation: 0,
      ),
    );
  }

  static ThemeData _darkTheme() {
    return ThemeData(
      fontFamily: 'Poppins',
      brightness: Brightness.light, // dim blue, not inverted Material dark
      scaffoldBackgroundColor: kDimBackground,
      colorScheme: const ColorScheme.light(
        primary: kPrimaryBlue,
        secondary: kPrimaryGreen,
        surface: kDimSurface,
        onSurface: kDimTextPrimary,
        onSurfaceVariant: kDimTextSecondary,
      ),
      cardColor: kDimSurface,
      dividerColor: kDimDivider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kDimInputFill,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kDimBackground,
        foregroundColor: kDimTextPrimary,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) {
            return GetMaterialApp(
              title: 'TravelMate',
              useInheritedMediaQuery: true,
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
              debugShowCheckedModeBanner: false,
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: mode,
              initialRoute: AppPages.initial,
              getPages: AppPages.routes,
            );
          },
        );
      },
    );
  }
}
