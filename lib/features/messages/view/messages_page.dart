import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/app_bottom_nav.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/features/messages/view/chat_page.dart';

class _ConversationPreview {
  final String name;
  final String initials;
  final Color avatarColor;
  final String time;
  final String route;
  final String tripInfo;
  final String lastMessage;
  final int unreadCount;
  final bool online;

  const _ConversationPreview({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.time,
    required this.route,
    required this.tripInfo,
    required this.lastMessage,
    this.unreadCount = 0,
    this.online = false,
  });
}

/// Messages list page — shows all conversations with passengers/drivers.
///
/// This page wraps itself in [SosScaffold] so the floating emergency SOS
/// button is available here. [ChatPage] (an individual conversation
/// thread) intentionally does NOT show the SOS button.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static final List<_ConversationPreview> _conversations = [
    _ConversationPreview(
      name: "Sarah Johnson",
      initials: "SJ",
      avatarColor: kPrimaryGreen,
      time: "2 min ago",
      route: "Lekki Phase 1 → Victoria Island",
      tripInfo: "Today, 8:00 AM",
      lastMessage: "Thanks! See you tomorrow at 8 AM",
      unreadCount: 2,
      online: true,
    ),
    _ConversationPreview(
      name: "Michael Adeyemi",
      initials: "MA",
      avatarColor: kPrimaryBlue,
      time: "15 min ago",
      route: "Ikeja → Maryland",
      tripInfo: "Today, 3:00 PM",
      lastMessage: "Can we meet at the bus stop instead?",
      online: true,
    ),
    _ConversationPreview(
      name: "Amaka Okafor",
      initials: "AO",
      avatarColor: kAmber,
      time: "1 hour ago",
      route: "Surulere → Yaba",
      tripInfo: "Tomorrow, 9:00 AM",
      lastMessage: "Perfect! I'll be there on time",
    ),
    _ConversationPreview(
      name: "Chidi Okonkwo",
      initials: "CO",
      avatarColor: Color(0xFF8B5CF6),
      time: "2 hours ago",
      route: "Ajah → Ikoyi",
      tripInfo: "Jan 16, 7:00 AM",
      lastMessage: "What time should I be ready?",
      unreadCount: 1,
    ),
    _ConversationPreview(
      name: "Blessing Nwosu",
      initials: "BN",
      avatarColor: Color(0xFFEC4899),
      time: "Yesterday",
      route: "Festac → VI",
      tripInfo: "Jan 13, 10:00 AM",
      lastMessage: "Thank you for the smooth ride!",
    ),
  ];

  void _openChat(BuildContext context, _ConversationPreview convo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          name: convo.name,
          initials: convo.initials,
          avatarColor: convo.avatarColor,
          online: convo.online,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _backButton(context),
                    const SizedBox(height: 12),
                    const Text(
                      "Messages",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Chat with your passengers",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    ..._conversations.map(
                      (c) => _conversationCard(context, c),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: const AppBottomNavBar(current: AppTab.chats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
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

  Widget _conversationCard(BuildContext context, _ConversationPreview c) {
    return InkWell(
      onTap: () => _openChat(context, c),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(c),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.time,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black38),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: kPrimaryBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.route,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryBlue),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.tripInfo,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87),
                  ),
                ),
                if (c.unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: kPrimaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${c.unreadCount}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(_ConversationPreview c) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                c.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (c.online)
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}