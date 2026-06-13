import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
///
/// Does NOT show the floating emergency SOS button — that lives on
/// [MessagesPage] (the conversation list) instead.
class ChatPage extends StatefulWidget {
  final String name;
  final String initials;
  final Color avatarColor;
  final bool online;

  const ChatPage({
    super.key,
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.online = true,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: "Hi! I just booked your ride. Is the pickup location at Lekki "
          "Phase 1 correct?",
      time: "09:15 AM",
      sender: _MessageSender.them,
    ),
    const _ChatMessage(
      text: "Yes, that's correct! I'll be there at 8:00 AM sharp.",
      time: "09:17 AM",
      sender: _MessageSender.me,
      read: true,
    ),
    const _ChatMessage(
      text: "Perfect! Should I wait by the main gate or inside the estate?",
      time: "09:18 AM",
      sender: _MessageSender.them,
    ),
    const _ChatMessage(
      text: "Please wait by the main gate. It's easier to find you there.",
      time: "09:20 AM",
      sender: _MessageSender.me,
      read: true,
    ),
    const _ChatMessage(
      text: "Great! Thanks for confirming. See you tomorrow!",
      time: "09:22 AM",
      sender: _MessageSender.them,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          time: _currentTime(),
          sender: _MessageSender.me,
          read: false,
        ),
      );
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: _messageList(),
            ),
            _composer(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
      decoration: BoxDecoration(
        color: kBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.online ? "Online" : "Offline",
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.online ? kPrimaryGreen : Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _circleIconButton(Icons.call_outlined, kPrimaryBlue),
          const SizedBox(width: 8),
          _circleIconButton(Icons.videocam_outlined, kPrimaryGreen),
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
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (widget.online)
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 11,
                height: 11,
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

  Widget _messageList() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        _dateChip("Today"),
        const SizedBox(height: 12),
        ..._messages.map(_messageBubble),
      ],
    );
  }

  Widget _dateChip(String label) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  color: Colors.black.withOpacity(0.04),
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
                style:
                    const TextStyle(fontSize: 11, color: Colors.black38),
              ),
              if (isMe && message.read) ...[
                const SizedBox(width: 4),
                const Icon(Icons.done_all,
                    size: 14, color: kPrimaryBlue),
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(Icons.attach_file, color: Colors.black45),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                child:
                    const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}