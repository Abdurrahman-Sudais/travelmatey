import 'package:travelmateeee/data/models/user_model.dart';

class RideModel {
  final String id;
  final String driverId;
  final String from;
  final String to;
  final String departureTime;
  final double pricePerSeat;
  final int availableSeats;
  final int totalSeats;
  final String status; // "open", "active", "cancelled", "completed"
  final String description;
  final String createdAt;

  final UserModel? driver;

  const RideModel({
    required this.id,
    required this.driverId,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.pricePerSeat,
    required this.availableSeats,
    required this.totalSeats,
    required this.status,
    required this.description,
    required this.createdAt,
    this.driver,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id']?.toString() ?? '',
      driverId:
          json['driverId']?.toString() ?? json['driver_id']?.toString() ?? '',
      from: json['from']?.toString() ?? json['origin']?.toString() ?? '',
      to: json['to']?.toString() ?? json['destination']?.toString() ?? '',
      departureTime: json['departureTime']?.toString() ??
          json['departure_time']?.toString() ??
          '',
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ??
          (json['price_per_seat'] as num?)?.toDouble() ??
          0.0,
      availableSeats: json['availableSeats'] as int? ??
          json['available_seats'] as int? ??
          1,
      totalSeats:
          json['totalSeats'] as int? ?? json['total_seats'] as int? ?? 4,
      status: json['status']?.toString() ?? 'open',
      description: json['description']?.toString() ?? '',
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      driver: json['driver'] != null
          ? UserModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
    );
  }

  factory RideModel.mock() => RideModel(
        id: 'ride_1',
        driverId: 'user_2',
        from: 'Lagos',
        to: 'Ibadan',
        departureTime: 'Jun 2, 2026 at 08:00',
        pricePerSeat: 5000.0,
        availableSeats: 2,
        totalSeats: 4,
        status: 'open',
        description: 'Mock ride description',
        createdAt: DateTime.now().toIso8601String(),
        driver: UserModel.mock().copyWith(name: 'Mock Driver'),
      );

  RideModel copyWith({
    String? id,
    String? driverId,
    String? from,
    String? to,
    String? departureTime,
    double? pricePerSeat,
    int? availableSeats,
    int? totalSeats,
    String? status,
    String? description,
    String? createdAt,
    UserModel? driver,
  }) {
    return RideModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      from: from ?? this.from,
      to: to ?? this.to,
      departureTime: departureTime ?? this.departureTime,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      driver: driver ?? this.driver,
    );
  }
}

