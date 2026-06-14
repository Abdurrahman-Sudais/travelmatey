import 'package:flutter/material.dart';

// ─── Brand colours (never change) ────────────────────────────────────────────
const Color kPrimaryGreen = Color(0xFF008000);
const Color kPrimaryBlue  = Color(0xFF0b6cb9);
const Color kErrorRed     = Color(0xFFFF4B4B);
const Color kAmber        = Color(0xFFF59E0B);
const Color kCallBackground = Color(0xFF1A1E2E);
const Color kCallSurface    = Color(0xFF34384E);

const Gradient kPrimaryGradient = LinearGradient(
  colors: [kPrimaryBlue, kPrimaryGreen],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ─── Dark-mode notifier ───────────────────────────────────────────────────────
/// A single global notifier.  Profile page writes it; everywhere else reads it.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

// ─── Convenience helper ───────────────────────────────────────────────────────
bool get isDark => themeModeNotifier.value == ThemeMode.dark;

// ─── Semantic / adaptive tokens ──────────────────────────────────────────────

/// Main page / scaffold background
Color get kBackground => isDark ? const Color(0xFF121212) : const Color(0xFFEBF3FB);

/// Surface colour used for cards, bottom sheets, nav bar
Color get kSurface => isDark ? const Color(0xFF1E1E1E) : Colors.white;

/// Slightly elevated surface (inside cards)
Color get kSurface2 => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7);

/// Divider / subtle border
Color get kDivider => isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0);

/// Primary text colour
Color get kTextPrimary => isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1A1A1A);

/// Secondary / muted text
Color get kTextSecondary => isDark ? const Color(0xFF9E9E9E) : Colors.black54;

/// Very subtle text (timestamps, labels)
Color get kTextHint => isDark ? const Color(0xFF6B6B6B) : Colors.black38;

/// Icon colour for non-primary icons
Color get kIconMuted => isDark ? const Color(0xFF9E9E9E) : Colors.black54;

/// Input / field fill
Color get kInputFill => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

/// Bottom-nav shadow overlay
Color get kNavShadow =>
    isDark ? Colors.black.withValues(alpha: 0.40) : Colors.black.withValues(alpha: 0.06);