/// Helpers for normalizing heterogeneous API response shapes.
class ApiParse {
  ApiParse._();

  static List<dynamic> asList(
    Map<String, dynamic> json, {
    List<String> keys = const [
      'data',
      'items',
      'results',
      'bookings',
      'rides',
      'chats',
      'conversations',
      'notifications',
      'referrals',
      'transactions',
    ],
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) return value;
    }
    return const [];
  }

  static Map<String, dynamic> asMap(
    Map<String, dynamic> json, {
    List<String> keys = const [
      'data',
      'wallet',
      'user',
      'profile',
      'ride',
      'booking',
      'message',
    ],
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return json;
  }
}
