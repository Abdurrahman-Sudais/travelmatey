import 'package:flutter/material.dart';

extension NumExtensions on num {
  /// Vertical spacing: `SizedBox(height: value)`
  Widget get sbH => SizedBox(height: toDouble());

  /// Horizontal spacing: `SizedBox(width: value)`
  Widget get sbW => SizedBox(width: toDouble());
}
