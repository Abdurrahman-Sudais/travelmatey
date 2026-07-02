import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/features/messages/view/call_page.dart';
import 'package:travelmateeee/data/repositories/chat_repository.dart';

enum _MessageSender { me, them }

class _ChatMessage {
  final String text;
  final String time;
  final _MessageSender sender;
  final bool read;

  const _ChatMessage({
    required this.text,
    required this.time,
    required this.sender,
    this.read = false,
  });
}

/// A single chat conversation thread.
class ChatPage extends StatefulWidget {
  final String conversationId;
  final String name;
  final String roleLabel;
  final String initials;
  final Color avatarColor;
  final String? phoneNumber;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.name,
    required this.roleLabel,
    required this.initials,
    required this.avatarColor,
    this.phoneNumber,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatRepository _chatRepo = Get.find<ChatRepository>();

  final List<_ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.instance.currentUser?.id;
    _ensureCurrentUser().then((_) => _loadMessages());
  }

  Future<void> _ensureCurrentUser() async {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) return;
    try {
      final user = await AuthService.instance.getMe();
      if (mounted) setState(() => _currentUserId = user.id);
    } catch (_) {}
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final list = await _chatRepo.getMessages(widget.conversationId);
      await _chatRepo.markAsRead(widget.conversationId);

      final userId = _currentUserId ?? AuthService.instance.currentUser?.id;

      setState(() {
        _messages
          ..clear()
          ..addAll(list.map((message) {
            final isMe = userId != null && message.senderId == userId;
            return _ChatMessage(
              text: message.content,
              time: _formatTimestamp(message.timestamp),
              sender: isMe ? _MessageSender.me : _MessageSender.them,
              read: message.isRead,
            );
          }));
        _isLoading = false;
      });
      _scrollToBottom(animate: false);
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to load messages',
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
    }
  }

  String _formatTimestamp(String raw) {
    if (raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          time: _currentTime(),
          sender: _MessageSender.me,
          read: false,
        ),
      );
    });
    _scrollToBottom();

    try {
      await _chatRepo.sendMessage(widget.conversationId, text);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message',
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  String _currentTime() {
    final now = TimeOfDay.now();
    final hour12 = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? "AM" : "PM";
    return "$hour12:$minute $period";
  }

  void _callParticipant() {
    final phone = widget.phoneNumber?.trim();
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'No phone number',
        'This contact has not shared a phone number yet.',
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceCallPage(
          name: widget.name,
          initials: widget.initials,
          avatarColor: widget.avatarColor,
          phoneNumber: phone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimaryBlue),
                    )
                  : _messageList(),
            ),
            _composer(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final hasPhone = widget.phoneNumber?.trim().isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
      decoration: BoxDecoration(
        color: kBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          _avatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.roleLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (hasPhone)
            GestureDetector(
              onTap: _callParticipant,
              child: _circleIconButton(Icons.call_outlined, kPrimaryBlue),
            ),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _avatar() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: widget.avatarColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _messageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'Say hello to ${widget.name.split(' ').first}',
          style: const TextStyle(color: Colors.black38, fontSize: 14),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: _messages.map(_messageBubble).toList(),
    );
  }

  Widget _messageBubble(_ChatMessage message) {
    final bool isMe = message.sender == _MessageSender.me;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? kPrimaryBlue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMe ? 14 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 13.5,
                color: isMe ? Colors.white : Colors.black87,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.time,
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
              if (isMe && message.read) ...[
                const SizedBox(width: 4),
                const Icon(Icons.done_all, size: 14, color: kPrimaryBlue),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: kPrimaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
