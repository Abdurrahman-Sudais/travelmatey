import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../theme/app_colors.dart';
import 'email_verification_page.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationPage({super.key, required this.phoneNumber});

  @override
  State<PhoneVerificationPage> createState() =>
      _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  int _secondsRemaining = 117;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _maskedNumber {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return widget.phoneNumber;
    final last3 = digits.substring(digits.length - 3);
    return "+234${digits.startsWith('0') ? digits.substring(1, 2) : digits.substring(0, 1)}******$last3";
  }

  bool get _isComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 4) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
    if (_isComplete) {
      // Auto-continue once all digits entered
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const EmailVerificationPage(
                      email: "abdurrahmansudais539@gmail.com",
                    )),
          );
        }
      });
    }
  }

  void _resend() {
    setState(() => _secondsRemaining = 117);
    _timer?.cancel();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          _backgroundRipples(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(),
                  const SizedBox(height: 60),
                  const Center(
                    child: Text(
                      "Phone verification",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                        children: [
                          const TextSpan(
                              text: "We've sent an SMS with an OTP "
                                  "code to\n"),
                          TextSpan(
                            text: _maskedNumber,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Enter your OTP Code",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54),
                      ),
                      Text(
                        "${_secondsRemaining}s",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kErrorRed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _otpRow(),
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                        children: [
                          const TextSpan(text: "Didn't receive code? "),
                          TextSpan(
                            text: "Resend again",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _secondsRemaining == 0
                                  ? kPrimaryBlue
                                  : Colors.black38,
                            ),
                            recognizer: _secondsRemaining == 0
                                ? (TapGestureRecognizer()
                                  ..onTap = _resend)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundRipples() {
    return Positioned(
      top: -100,
      right: -100,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.4,
          child: SizedBox(
            width: 360,
            height: 360,
            child: CustomPaint(painter: _RipplePainter()),
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chevron_left, size: 22, color: Colors.black87),
          Text("Back",
              style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _otpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        return SizedBox(
          width: 56,
          height: 64,
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: const Color(0xFFEDEDED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryBlue, width: 1.5),
              ),
            ),
            onChanged: (v) => _onChanged(i, v),
          ),
        );
      }),
    );
  }
}

class _RipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width, 0);
    for (int i = 1; i <= 6; i++) {
      canvas.drawCircle(center, i * 30.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}