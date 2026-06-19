import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';

class RequestSentPage extends StatelessWidget {
  const RequestSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(context),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        "A booking request has been sent, You will be "
                        "notified to confirm by making payment once your "
                        "request is accepted by the Driver!",
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Home",
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chevron_left, size: 22, color: Colors.black87),
              Text("Back", style: TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, size: 24, color: Colors.black87),
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kErrorRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}