import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onTap;

  const GoogleSignInButton({
    super.key,
    required this.enabled,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled && !isLoading ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'G',
                    style: TextStyle(
                      color: enabled
                          ? const Color(0xFF4285F4)
                          : Colors.black38,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.black87 : Colors.black38,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
