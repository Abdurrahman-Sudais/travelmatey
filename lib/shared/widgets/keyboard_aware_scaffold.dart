import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

/// Form scaffold that lifts content above the keyboard.
///
/// Wraps [SosScaffold] + [Scaffold] with `resizeToAvoidBottomInset: true` and
/// applies [MediaQuery.viewInsets.bottom] so fields and bottom bars stay visible.
class KeyboardAwareFormScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomBar;
  final bool showSos;
  final Color? backgroundColor;
  final EdgeInsets scrollPadding;

  const KeyboardAwareFormScaffold({
    super.key,
    required this.body,
    this.bottomBar,
    this.showSos = true,
    this.backgroundColor,
    this.scrollPadding = const EdgeInsets.fromLTRB(16, 12, 16, 20),
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    final content = Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor ?? kBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: bottomBar == null
              ? body
              : Column(
                  children: [
                    Expanded(child: body),
                    bottomBar!,
                  ],
                ),
        ),
      ),
    );

    if (!showSos) return content;
    return SosScaffold(child: content);
  }
}

/// Scrollable form body — pass as [KeyboardAwareFormScaffold.body].
class KeyboardAwareScrollBody extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollController? controller;

  const KeyboardAwareScrollBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 20),
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: padding.copyWith(
        bottom: padding.bottom + (keyboardHeight > 0 ? 24 : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
