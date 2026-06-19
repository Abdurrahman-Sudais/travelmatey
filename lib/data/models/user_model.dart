/// User profile DTO — mirrors expected backend `GET /users/me` response.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final double rating;
  final int tripCount;
  final String memberSince;
  final String street;
  final String city;
  final String state;
  final String lga;
  final bool kycVerified;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.rating,
    required this.tripCount,
    required this.memberSince,
    required this.street,
    required this.city,
    required this.state,
    required this.lga,
    required this.kycVerified,
  });

  factory UserModel.mock() => const UserModel(
        id: 'user_1',
        name: 'Michael Adeyemi',
        email: 'michael.adeyemi@example.com',
        phone: '+234 803 123 4567',
        rating: 4.8,
        tripCount: 47,
        memberSince: 'January 2024',
        street: '15 Admiralty Way, Lekki Phase 1',
        city: 'Lagos',
        state: 'Lagos',
        lga: 'Eti-Osa',
        kycVerified: false,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString(),
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        tripCount: json['trip_count'] as int? ?? 0,
        memberSince: json['member_since']?.toString() ?? '',
        street: json['street']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        lga: json['lga']?.toString() ?? '',
        kycVerified: json['kyc_verified'] as bool? ?? false,
      );

  UserModel copyWith({
    String? avatarUrl,
    String? street,
    String? city,
    String? state,
    String? lga,
    bool? kycVerified,
  }) =>
      UserModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        rating: rating,
        tripCount: tripCount,
        memberSince: memberSince,
        street: street ?? this.street,
        city: city ?? this.city,
        state: state ?? this.state,
        lga: lga ?? this.lga,
        kycVerified: kycVerified ?? this.kycVerified,
      );
}
