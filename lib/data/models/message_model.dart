class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id']?.toString() ?? '',
        conversationId: json['conversationId']?.toString() ??
            json['conversation_id']?.toString() ??
            json['chatId']?.toString() ??
            json['chat_id']?.toString() ??
            '',
        senderId: json['senderId']?.toString() ??
            json['sender_id']?.toString() ??
            json['userId']?.toString() ??
            json['user_id']?.toString() ??
            '',
        content: json['content']?.toString() ??
            json['message']?.toString() ??
            json['text']?.toString() ??
            '',
        timestamp: json['timestamp']?.toString() ??
            json['createdAt']?.toString() ??
            json['created_at']?.toString() ??
            '',
        isRead: json['isRead'] as bool? ??
            json['is_read'] as bool? ??
            json['read'] as bool? ??
            false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'timestamp': timestamp,
        'is_read': isRead,
      };
}
