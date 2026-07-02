import 'package:travelmateeee/data/models/user_model.dart';
import 'package:travelmateeee/data/models/ride_model.dart';

class BookingModel {
  final String id;
  final String rideId;
  final String riderId;
  final int seatsBooked;
  final double totalPrice;
  final String status; // "pending", "accepted", "confirmed", "cancelled", "completed"
  final String paymentStatus;
  final String createdAt;
  
  // Nested relational data that the API might return
  final RideModel? ride;
  final UserModel? driver;
  final UserModel? rider;

  const BookingModel({
    required this.id,
    required this.rideId,
    required this.riderId,
    required this.seatsBooked,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.ride,
    this.driver,
    this.rider,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      rideId: json['rideId']?.toString() ?? json['ride_id']?.toString() ?? '',
      riderId:
          json['riderId']?.toString() ?? json['rider_id']?.toString() ?? '',
      seatsBooked: json['seatsBooked'] as int? ??
          json['seats_booked'] as int? ??
          1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ??
          (json['total_price'] as num?)?.toDouble() ??
          0.0,
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ??
          json['payment_status']?.toString() ??
          'pending',
      createdAt: json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          '',
      ride: json['ride'] != null
          ? RideModel.fromJson(json['ride'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] != null
          ? UserModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      rider: json['rider'] != null
          ? UserModel.fromJson(json['rider'] as Map<String, dynamic>)
          : null,
    );
  }

  factory BookingModel.mockPending() => BookingModel(
        id: 'booking_1',
        rideId: 'ride_1',
        riderId: 'user_1',
        seatsBooked: 2,
        totalPrice: 10000.0,
        status: 'pending',
        paymentStatus: 'pending',
        createdAt: DateTime.now().toIso8601String(),
        driver: UserModel.mock().copyWith(name: 'Mock Driver'),
        ride: RideModel.mock(),
      );
      
  factory BookingModel.mockAccepted() => BookingModel.mockPending().copyWith(status: 'accepted');
  factory BookingModel.mockPaid() => BookingModel.mockPending().copyWith(status: 'confirmed', paymentStatus: 'paid');
  factory BookingModel.mockCompleted() => BookingModel.mockPending().copyWith(status: 'completed', paymentStatus: 'paid');

  BookingModel copyWith({
    String? status,
    String? paymentStatus,
  }) {
    return BookingModel(
      id: id,
      rideId: rideId,
      riderId: riderId,
      seatsBooked: seatsBooked,
      totalPrice: totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      ride: ride,
      driver: driver,
      rider: rider,
    );
  }
}
