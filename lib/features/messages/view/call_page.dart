import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';

/// Full-screen voice call UI (matches the "Voice Call" / ringing screen).
class VoiceCallPage extends StatefulWidget {
  final String name;
  final String initials;
  final Color avatarColor;
  final String phoneNumber;

  const VoiceCallPage({
    super.key,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.phoneNumber,
  });

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  Timer? _timer;
  int _seconds = 0;
  bool _connected = false;
  bool _micMuted = false;
  bool _speakerOn = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _connected = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _statusText {
    if (!_connected) return "Ringing...";
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCallBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              callTypeBadge("Voice Call"),
              const Spacer(flex: 3),
              callAvatar(initials: widget.initials, color: widget.avatarColor),
              const SizedBox(height: 28),
              Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.phoneNumber,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
              ),
              const SizedBox(height: 20),
              callStatusChip(_statusText),
              const Spacer(flex: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  callControlButton(
                    icon: _micMuted ? Icons.mic_off : Icons.mic,
                    onTap: () => setState(() => _micMuted = !_micMuted),
                    active: _micMuted,
                  ),
                  callControlButton(
                    icon: Icons.call_end,
                    onTap: _endCall,
                    background: kErrorRed,
                    size: 64,
                    iconSize: 28,
                  ),
                  callControlButton(
                    icon: _speakerOn ? Icons.volume_up : Icons.volume_down,
                    onTap: () => setState(() => _speakerOn = !_speakerOn),
                    active: _speakerOn,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen video call UI (matches the "Video Call" screen with the
/// "You" picture-in-picture preview top-right).
class VideoCallPage extends StatefulWidget {
  final String name;
  final String initials;
  final Color avatarColor;
  final String phoneNumber;

  const VideoCallPage({
    super.key,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.phoneNumber,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  Timer? _timer;
  int _seconds = 0;
  bool _connected = false;
  bool _micMuted = false;
  bool _speakerOn = false;
  bool _cameraOff = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _connected = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _statusText {
    if (!_connected) return "Ringing...";
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.maybePop(context);
  }

  void _flipCamera() {
    // TODO: hook up to camera package to switch front/back camera.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video placeholder (the other person's feed).
            Positioned.fill(
              child: Center(
                child: callAvatar(
                  initials: widget.initials,
                  color: widget.avatarColor,
                  size: 160,
                  fontSize: 56,
                ),
              ),
            ),
            // Top-left: call type badge.
            Positioned(top: 24, left: 24, child: callTypeBadge("Video Call")),
            // Top-right: local camera preview ("You").
            Positioned(top: 24, right: 24, child: _localPreview()),
            if (!_connected)
              Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: Center(child: callStatusChip(_statusText)),
              ),
            // Bottom controls.
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      callControlButton(
                        icon: _micMuted ? Icons.mic_off : Icons.mic,
                        onTap: () => setState(() => _micMuted = !_micMuted),
                        active: _micMuted,
                      ),
                      callControlButton(
                        icon: Icons.call_end,
                        onTap: _endCall,
                        background: kErrorRed,
                        size: 64,
                        iconSize: 28,
                      ),
                      callControlButton(
                        icon: _speakerOn ? Icons.volume_up : Icons.volume_down,
                        onTap: () => setState(() => _speakerOn = !_speakerOn),
                        active: _speakerOn,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      callControlButton(
                        icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                        onTap: () => setState(() => _cameraOff = !_cameraOff),
                        active: _cameraOff,
                      ),
                      const SizedBox(width: 20),
                      callControlButton(icon: Icons.cached, onTap: _flipCamera),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _localPreview() {
    return Container(
      width: 110,
      height: 150,
      decoration: BoxDecoration(
        color: kCallSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      alignment: Alignment.center,
      child: _cameraOff
          ? const Icon(Icons.videocam_off, color: Colors.white54, size: 24)
          : Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(color: kPrimaryBlue, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text(
                "You",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
    );
  }
}

// ─── Shared widgets used by both call screens ──────────────────────────────

Widget callTypeBadge(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: kCallSurface, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: kPrimaryGreen, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget callAvatar({required String initials, required Color color, double size = 180, double fontSize = 64}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: size + 60,
        height: size + 60,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
      ),
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 40, spreadRadius: 10)],
        ),
        alignment: Alignment.center,
        child: Text(initials, style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold)),
      ),
    ],
  );
}

Widget callStatusChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: BoxDecoration(color: kCallSurface, borderRadius: BorderRadius.circular(30)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
  );
}

Widget callControlButton({
  required IconData icon,
  required VoidCallback onTap,
  Color? background,
  bool active = false,
  double size = 56,
  double iconSize = 22,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(size / 2),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background ?? (active ? Colors.white : kCallSurface), shape: BoxShape.circle),
      child: Icon(
        icon,
        color: background != null ? Colors.white : (active ? kCallBackground : Colors.white),
        size: iconSize,
      ),
    ),
  );
}