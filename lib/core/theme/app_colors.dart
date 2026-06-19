import 'package:flutter/material.dart';

// ─── Brand colours (never change) ────────────────────────────────────────────
const Color kPrimaryGreen = Color(0xFF008000);
const Color kPrimaryBlue = Color(0xFF0b6cb9);
const Color kErrorRed = Color(0xFFFF4B4B);
const Color kAmber = Color(0xFFF59E0B);
const Color kCallBackground = Color(0xFF1A1E2E);
const Color kCallSurface = Color(0xFF34384E);

const Gradient kPrimaryGradient = LinearGradient(
  colors: [kPrimaryBlue, kPrimaryGreen],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ─── Light palette (base) ─────────────────────────────────────────────────────
const Color kLightBackground = Color(0xFFEBF3FB);
const Color kLightSurface = Color(0xFFFFFFFF);
const Color kLightSurface2 = Color(0xFFF7F7F7);
const Color kLightDivider = Color(0xFFF0F0F0);
const Color kLightTextPrimary = Color(0xFF1A1A1A);
const Color kLightTextSecondary = Color(0x8A000000); // black54
const Color kLightTextHint = Color(0x61000000); // black38
const Color kLightInputFill = Color(0xFFF5F5F5);

// ─── Dim palette — slightly deeper blues, NOT black ────────────────────────────
const Color kDimBackground = Color(0xFFC5D9EC);
const Color kDimSurface = Color(0xFFD9E8F5);
const Color kDimSurface2 = Color(0xFFB8CFE3);
const Color kDimDivider = Color(0xFFA8C0D6);
const Color kDimTextPrimary = Color(0xFF1A2A3A);
const Color kDimTextSecondary = Color(0xFF4A6278);
const Color kDimTextHint = Color(0xFF6B8499);
const Color kDimInputFill = Color(0xFFADC4D9);

// ─── Dark-mode notifier ───────────────────────────────────────────────────────
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

bool get isDark => themeModeNotifier.value == ThemeMode.dark;

// ─── Semantic / adaptive tokens ──────────────────────────────────────────────

Color get kBackground => isDark ? kDimBackground : kLightBackground;

Color get kSurface => isDark ? kDimSurface : kLightSurface;

Color get kSurface2 => isDark ? kDimSurface2 : kLightSurface2;

Color get kDivider => isDark ? kDimDivider : kLightDivider;

Color get kTextPrimary => isDark ? kDimTextPrimary : kLightTextPrimary;

Color get kTextSecondary => isDark ? kDimTextSecondary : kLightTextSecondary;

Color get kTextHint => isDark ? kDimTextHint : kLightTextHint;

Color get kIconMuted => kTextSecondary;

Color get kInputFill => isDark ? kDimInputFill : kLightInputFill;

Color get kNavShadow => isDark
    ? const Color(0xFF8FAEC5).withValues(alpha: 0.35)
    : Colors.black.withValues(alpha: 0.06);

/// Tinted upload / info box background (adapts to dim mode)
Color get kUploadBoxFill =>
    isDark ? const Color(0xFFB8D4EA) : const Color(0xFFEFF6FF);
