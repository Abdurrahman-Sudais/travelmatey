import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/base/active_role.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/features/home/view/home_page.dart' show activeRoleNotifier;
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/shared/widgets/conditional_back_button.dart';
import 'package:travelmateeee/features/messages/view/chat_page.dart';
import 'package:travelmateeee/data/repositories/chat_repository.dart';
import 'package:travelmateeee/data/models/conversation_model.dart';

class _ConversationPreview {
  final String id;
  final String name;
  final String roleLabel;
  final String initials;
  final Color avatarColor;
  final String time;
  final String? route;
  final String? tripInfo;
  final String lastMessage;
  final int unreadCount;
  final String? phone;

  const _ConversationPreview({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.initials,
    required this.avatarColor,
    required this.time,
    this.route,
    this.tripInfo,
    required this.lastMessage,
    this.unreadCount = 0,
    this.phone,
  });
}

/// Messages list — driver sees passenger threads; rider sees driver threads.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatRepository _chatRepo = Get.find<ChatRepository>();
  List<_ConversationPreview> _conversations = [];
  bool _isLoading = true;
  String? _error;

  bool get _isDriver =>
      activeRoleNotifier.value == ActiveRole.driver ||
      AuthService.instance.currentUser?.role == 'driver';

  @override
  void initState() {
    super.initState();
    activeRoleNotifier.addListener(_onRoleChanged);
    _loadConversations();
  }

  @override
  void dispose() {
    activeRoleNotifier.removeListener(_onRoleChanged);
    super.dispose();
  }

  void _onRoleChanged() {
    _loadConversations();
  }

  String get _viewerRole => _isDriver ? 'driver' : 'rider';

  String _roleLabelFor(ConversationModel conversation) {
    final role = conversation.participantRole?.toLowerCase();
    if (role == 'driver') return 'Driver';
    if (role == 'rider' || role == 'passenger') return 'Passenger';
    return _isDriver ? 'Passenger' : 'Driver';
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _chatRepo.getConversations(viewerRole: _viewerRole);
      const colors = [
        kPrimaryGreen,
        kPrimaryBlue,
        kAmber,
        Color(0xFF8B5CF6),
        Color(0xFFEC4899),
      ];

      setState(() {
        _conversations = list.asMap().entries.map((entry) {
          final index = entry.key;
          final conversation = entry.value;
          final initials = conversation.participantName
              .split(' ')
              .where((part) => part.isNotEmpty)
              .map((part) => part[0])
              .take(2)
              .join()
              .toUpperCase();

          return _ConversationPreview(
            id: conversation.id,
            name: conversation.participantName,
            roleLabel: _roleLabelFor(conversation),
            initials: initials.isNotEmpty ? initials : 'U',
            avatarColor: colors[index % colors.length],
            time: conversation.lastMessageTime,
            route: conversation.rideRoute,
            tripInfo: conversation.tripDate,
            lastMessage: conversation.lastMessage,
            unreadCount: conversation.unreadCount,
            phone: conversation.participantPhone,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _startNewConversation() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _isDriver ? 'Message a Passenger' : 'Message a Driver',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isDriver
                  ? 'Enter the booking ID or conversation ID to contact your passenger.'
                  : 'Chats are created when a driver accepts your booking.\nCheck your Bookings tab to start a conversation.',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            if (_isDriver) ...[
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Conversation / Booking ID',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (_isDriver)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue),
              onPressed: () {
                final id = controller.text.trim();
                if (id.isNotEmpty) {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        conversationId: id,
                        name: 'Passenger',
                        roleLabel: 'Passenger',
                        initials: 'P',
                        avatarColor: kPrimaryBlue,
                      ),
                    ),
                  ).then((_) => _loadConversations());
                }
              },
              child: const Text('Open Chat',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, _ConversationPreview convo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId: convo.id,
          name: convo.name,
          roleLabel: convo.roleLabel,
          initials: convo.initials,
          avatarColor: convo.avatarColor,
          phoneNumber: convo.phone,
        ),
      ),
    ).then((_) => _loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimaryBlue,
          tooltip: _isDriver ? 'New message to passenger' : 'New message to driver',
          onPressed: _startNewConversation,
          child: const Icon(Icons.message_outlined, color: Colors.white),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimaryBlue),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ConditionalBackButton(),
                        const SizedBox(height: 12),
                        const Text(
                          "Messages",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isDriver
                              ? "Chat with passengers on your trips"
                              : "Chat with your driver or travel mates",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (_error != null) ...[
                          _errorBanner(),
                          const SizedBox(height: 12),
                        ],
                        if (_conversations.isEmpty && _error == null)
                          _emptyState()
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              return _conversationCard(context, _conversations[index]);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kErrorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kErrorRed.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: kErrorRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not load messages. Pull to refresh.',
              style: TextStyle(fontSize: 13, color: kErrorRed.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(
              _isDriver ? Icons.people_outline : Icons.directions_car_outlined,
              size: 48,
              color: Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              _isDriver
                  ? "No passenger messages yet"
                  : "No messages yet",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isDriver
                  ? "Messages appear when riders book your trips."
                  : "Start a chat from an active booking or accepted ride.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black38),
            ),
          ],
        ),
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
              color: Colors.black.withValues(alpha: 0.04),
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _isDriver
                              ? kPrimaryGreen.withValues(alpha: 0.12)
                              : kPrimaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.roleLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _isDriver ? kPrimaryGreen : kPrimaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (c.route != null && c.route!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: kPrimaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.route!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryBlue,
                            ),
                          ),
                          if (c.tripInfo != null && c.tripInfo!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              c.tripInfo!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.lastMessage.isNotEmpty ? c.lastMessage : 'No messages yet',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.lastMessage.isNotEmpty
                          ? Colors.black87
                          : Colors.black38,
                      fontStyle: c.lastMessage.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
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
                        fontWeight: FontWeight.bold,
                      ),
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
    return Container(
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
