import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchPhoneCall(String number, {BuildContext? context}) async {
  final digits = number.replaceAll(RegExp(r'[^\d+]'), '');
  if (digits.isEmpty) return false;

  final uri = Uri(scheme: 'tel', path: digits);
  if (!await canLaunchUrl(uri)) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot dial $number on this device')),
      );
    }
    return false;
  }
  return launchUrl(uri);
}

Future<bool> launchEmail(String email, {String? subject}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: email,
    query: subject != null ? 'subject=${Uri.encodeComponent(subject)}' : null,
  );
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri);
}
