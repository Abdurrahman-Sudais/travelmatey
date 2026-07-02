import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show MapboxOptions;
import 'package:travelmateeee/app/routes.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/di/service_locator.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/firebase_bootstrap.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── WEB-ONLY: CORS ───────────────────────────────────────────────────────
  // Browsers block cross-origin API calls. Prefer Android/iOS for API testing:
  //   flutter run -d android
  //
  // If you must use Chrome locally, pick ONE of these:
  //   A) Disable CORS in Chrome (dev only — see .vscode/launch.json):
  //      flutter run -d chrome --web-browser-flag "--disable-web-security" \
  //        --web-browser-flag "--user-data-dir=.chrome-dev-profile"
  //   B) Route requests through a public CORS proxy (unreliable, dev only):
  //      flutter run -d chrome --dart-define=USE_WEB_CORS_PROXY=true
  //      or set ApiService.useWebCorsProxy = true below.
  if (kIsWeb && kDebugMode) {
    const useProxy = bool.fromEnvironment('USE_WEB_CORS_PROXY');
    ApiService.useWebCorsProxy = useProxy;
    if (!useProxy) {
      debugPrint(
        'TravelMate web: API calls may fail with CORS. '
        'Run on Android or use the "Chrome — CORS disabled" launch config.',
      );
    }
  }

  await ServiceLocator.init();
  // Firebase is only required for phone OTP — Google Sign-In uses google_sign_in + your API.
  if (!AppConfig.useMockRepositories) {
    await FirebaseBootstrap.init();
  }

  MapboxOptions.setAccessToken(AppConfig.mapboxPublicToken);

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
