import 'package:flutter/material.dart';

/// Shows a back control only when this screen was pushed on the stack.
/// Hides on root tab pages inside [MainShell].
class ConditionalBackButton extends StatelessWidget {
  const ConditionalBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text('Back', style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}
