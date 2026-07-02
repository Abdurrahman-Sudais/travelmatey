import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/app/routes.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/base/active_role.dart';
import 'package:travelmateeee/features/home/view/home_page.dart' show activeRoleNotifier;
import 'package:travelmateeee/core/theme/app_colors.dart';

/// Startup gate: wakes the API, validates session, routes to home or onboarding.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showConnecting = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (AppConfig.useMockRepositories) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      if (ApiService.instance.isLoggedIn()) {
        Get.offAllNamed(RouteConstants.HOME);
      } else {
        _goOnboarding();
      }
      return;
    }

    // Timer for 3 seconds to show connecting
    final connectingTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showConnecting = true);
    });

    try {
      // 10 second timeout for the health check
      await ApiService.instance.get('/health').timeout(const Duration(seconds: 10));
      
      connectingTimer.cancel();
      if (mounted) setState(() => _showConnecting = false);
      
      if (!ApiService.instance.isLoggedIn()) {
        _goOnboarding();
        return;
      }

      final user = await AuthService.instance.validateSession();
      if (!mounted) return;

      if (user != null) {
        activeRoleNotifier.value =
            user.role == 'driver' ? ActiveRole.driver : ActiveRole.rider;
        Get.offAllNamed(RouteConstants.HOME);
      } else {
        _goOnboarding();
      }
    } catch (_) {
      connectingTimer.cancel();
      if (mounted) setState(() => _showError = true);
    }
  }

  void _goOnboarding() {
    Get.offAllNamed(RouteConstants.ONBOARDING);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            if (_showConnecting && !_showError)
              Container(
                width: double.infinity,
                color: kPrimaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Connecting to server...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_showError) const CircularProgressIndicator(color: kPrimaryBlue),
                    const SizedBox(height: 24),
                    Text(
                      _showError ? 'Server is unavailable.\nPlease try again later.' : 'Loading TravelMate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _showError ? kErrorRed : kTextPrimary,
                      ),
                    ),
                    if (_showError) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showError = false;
                            _showConnecting = false;
                          });
                          _bootstrap();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
