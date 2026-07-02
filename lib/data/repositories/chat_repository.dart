import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/data/models/conversation_model.dart';
import 'package:travelmateeee/data/models/message_model.dart';

abstract class ChatRepository {
  Future<List<ConversationModel>> getConversations({String? viewerRole});
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> sendMessage(String conversationId, String content);
  Future<void> markAsRead(String conversationId);
  Future<int> getTotalUnreadCount();
}

List<dynamic> _extractList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value;
  }
  return const [];
}

Map<String, dynamic> _extractObject(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  final message = json['message'];
  if (message is Map<String, dynamic>) return message;
  if (message is Map) return Map<String, dynamic>.from(message);
  return json;
}

class MockChatRepository implements ChatRepository {
  @override
  Future<List<ConversationModel>> getConversations({String? viewerRole}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [];
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [];
  }

  @override
  Future<MessageModel> sendMessage(String conversationId, String content) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MessageModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'local',
      content: content,
      timestamp: DateTime.now().toIso8601String(),
      isRead: true,
    );
  }

  @override
  Future<void> markAsRead(String conversationId) async {}

  @override
  Future<int> getTotalUnreadCount() async => 0;
}

class RemoteChatRepository implements ChatRepository {
  RemoteChatRepository();
  final ApiService _api = ApiService.instance;

  @override
  Future<List<ConversationModel>> getConversations({String? viewerRole}) async {
    final userId = _api.getUserId();
    List<ConversationModel> conversations = [];

    if (userId != null && userId.isNotEmpty) {
      try {
        final json = await _api.get(ApiEndpoints.userChats(userId));
        final list = _extractList(json, ['chats', 'conversations', 'data']);
        conversations = list
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fall through to legacy endpoint.
      }
    }

    if (conversations.isEmpty) {
      final json = await _api.get(ApiEndpoints.chat);
      final list = _extractList(json, ['conversations', 'chats', 'data']);
      conversations = list
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (viewerRole == null || viewerRole.isEmpty) {
      return conversations;
    }

    return conversations.where((conversation) {
      final role = conversation.participantRole?.toLowerCase();
      if (role == null || role.isEmpty) return true;
      if (viewerRole == 'driver') {
        return role == 'rider' || role == 'passenger';
      }
      return role == 'driver';
    }).toList();
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final json = await _api.get(ApiEndpoints.chatMessagesNew(conversationId));
      final list = _extractList(json, ['messages', 'data']);
      return list
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final json = await _api.get(ApiEndpoints.chatMessages(conversationId));
      final list = _extractList(json, ['messages', 'data']);
      return list
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  @override
  Future<MessageModel> sendMessage(String conversationId, String content) async {
    try {
      final json = await _api.post(
        ApiEndpoints.chatMessagesNew(conversationId),
        body: {'content': content, 'type': 'text'},
      );
      return MessageModel.fromJson(_extractObject(json));
    } catch (_) {
      final json = await _api.post(
        ApiEndpoints.chatMessages(conversationId),
        body: {'content': content},
      );
      return MessageModel.fromJson(_extractObject(json));
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    try {
      await _api.put(ApiEndpoints.chatRead(conversationId));
    } catch (_) {}
  }

  @override
  Future<int> getTotalUnreadCount() async {
    final userId = _api.getUserId();
    if (userId == null || userId.isEmpty) return 0;

    try {
      final json = await _api.get(ApiEndpoints.chatUnread(userId));
      final total = json['total'] ?? json['totalUnread'] ?? json['total_unread'];
      if (total is int) return total;
      if (total is num) return total.toInt();

      final counts = json['counts'];
      if (counts is Map) {
        return counts.values
            .whereType<num>()
            .fold<int>(0, (sum, value) => sum + value.toInt());
      }

      final chats = json['chats'];
      if (chats is List) {
        return chats
            .whereType<Map>()
            .map((chat) =>
                chat['unreadCount'] as int? ?? chat['unread_count'] as int? ?? 0)
            .fold<int>(0, (sum, count) => sum + count);
      }
    } catch (_) {}

    try {
      final conversations = await getConversations();
      return conversations.fold<int>(
        0,
        (sum, conversation) => sum + conversation.unreadCount,
      );
    } catch (_) {
      return 0;
    }
  }
}

ChatRepository createChatRepository() {
  if (AppConfig.useMockRepositories) return MockChatRepository();
  return RemoteChatRepository();
}
