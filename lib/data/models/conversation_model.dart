class ConversationModel {
  final String id;
  final String participantName;
  final String? participantAvatar;
  final String? participantPhone;
  final String? participantRole;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final String? rideRoute;
  final String? tripDate;
  final String? bookingId;

  const ConversationModel({
    required this.id,
    required this.participantName,
    this.participantAvatar,
    this.participantPhone,
    this.participantRole,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.rideRoute,
    this.tripDate,
    this.bookingId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final other = json['otherUser'] as Map<String, dynamic>? ??
        json['other_user'] as Map<String, dynamic>? ??
        json['participant'] as Map<String, dynamic>?;

    final firstName = json['participantFirstName']?.toString() ??
        json['participant_first_name']?.toString() ??
        other?['firstName']?.toString() ??
        other?['first_name']?.toString() ??
        '';
    final lastName = json['participantLastName']?.toString() ??
        json['participant_last_name']?.toString() ??
        other?['lastName']?.toString() ??
        other?['last_name']?.toString() ??
        '';
    final composedName = '$firstName $lastName'.trim();

    final from = json['from']?.toString() ??
        json['origin']?.toString() ??
        json['pickup']?.toString() ??
        json['rideFrom']?.toString() ??
        json['ride_from']?.toString();
    final to = json['to']?.toString() ??
        json['destination']?.toString() ??
        json['dropoff']?.toString() ??
        json['rideTo']?.toString() ??
        json['ride_to']?.toString();
    final route = json['rideRoute']?.toString() ??
        json['ride_route']?.toString() ??
        json['route']?.toString() ??
        (from != null && to != null ? '$from → $to' : null);

    return ConversationModel(
      id: json['id']?.toString() ??
          json['chatId']?.toString() ??
          json['chat_id']?.toString() ??
          json['conversationId']?.toString() ??
          json['conversation_id']?.toString() ??
          '',
      participantName: json['participantName']?.toString() ??
          json['participant_name']?.toString() ??
          json['name']?.toString() ??
          other?['name']?.toString() ??
          (composedName.isNotEmpty ? composedName : 'Travel mate'),
      participantAvatar: json['participantAvatar']?.toString() ??
          json['participant_avatar']?.toString() ??
          other?['avatar']?.toString() ??
          other?['avatarUrl']?.toString(),
      participantPhone: json['participantPhone']?.toString() ??
          json['participant_phone']?.toString() ??
          other?['phone']?.toString(),
      participantRole: json['participantRole']?.toString() ??
          json['participant_role']?.toString() ??
          json['otherUserRole']?.toString() ??
          json['other_user_role']?.toString() ??
          other?['role']?.toString(),
      lastMessage: json['lastMessage']?.toString() ??
          json['last_message']?.toString() ??
          json['latestMessage']?.toString() ??
          json['latest_message']?.toString() ??
          '',
      lastMessageTime: json['lastMessageTime']?.toString() ??
          json['last_message_time']?.toString() ??
          json['updatedAt']?.toString() ??
          json['updated_at']?.toString() ??
          '',
      unreadCount: json['unreadCount'] as int? ??
          json['unread_count'] as int? ??
          json['unread'] as int? ??
          0,
      rideRoute: route,
      tripDate: json['tripDate']?.toString() ??
          json['trip_date']?.toString() ??
          json['departureTime']?.toString() ??
          json['departure_time']?.toString() ??
          json['scheduledAt']?.toString() ??
          json['scheduled_at']?.toString(),
      bookingId: json['bookingId']?.toString() ??
          json['booking_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'participant_name': participantName,
        'participant_avatar': participantAvatar,
        'participant_phone': participantPhone,
        'participant_role': participantRole,
        'last_message': lastMessage,
        'last_message_time': lastMessageTime,
        'unread_count': unreadCount,
        'ride_route': rideRoute,
        'trip_date': tripDate,
        'booking_id': bookingId,
      };
}
