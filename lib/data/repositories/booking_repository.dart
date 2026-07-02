import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/utils/api_parse.dart';
import 'package:travelmateeee/data/models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getDriverPendingBookings();
  Future<List<BookingModel>> getUserBookings(String userId);
  /// Create a booking for the given ride. [seats] defaults to 1.
  Future<BookingModel> createBooking(String rideId, {int seats = 1});
  Future<void> acceptBooking(String bookingId);
  Future<void> rejectBooking(String bookingId);
  Future<void> cancelBooking(String bookingId, String reason);
  Future<void> completeBooking(String bookingId);
}

class MockBookingRepository implements BookingRepository {
  @override
  Future<List<BookingModel>> getDriverPendingBookings() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [];
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [];
  }

  @override
  Future<BookingModel> createBooking(String rideId, {int seats = 1}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return BookingModel.mockPending();
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> rejectBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> cancelBooking(String bookingId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> completeBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

class RemoteBookingRepository implements BookingRepository {
  final ApiService _api = ApiService.instance;

  @override
  Future<List<BookingModel>> getDriverPendingBookings() async {
    final response = await _api.get(ApiEndpoints.bookingsDriverPending);
    final list = ApiParse.asList(response, keys: const ['bookings', 'data']);
    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _api.get(ApiEndpoints.userBookings(userId));
    final list = ApiParse.asList(response, keys: const ['bookings', 'data']);
    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BookingModel> createBooking(String rideId, {int seats = 1}) async {
    final response = await _api.post(
      ApiEndpoints.bookings,
      body: {'rideId': rideId, 'seats': seats},
    );
    final data = response['booking'] as Map<String, dynamic>? ??
        response['data'] as Map<String, dynamic>? ??
        Map<String, dynamic>.from(response);
    return BookingModel.fromJson(data);
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await _api.put('${ApiEndpoints.booking(bookingId)}/accept');
  }

  @override
  Future<void> rejectBooking(String bookingId) async {
    await _api.put('${ApiEndpoints.booking(bookingId)}/reject');
  }

  @override
  Future<void> cancelBooking(String bookingId, String reason) async {
    await _api.put(
      '${ApiEndpoints.booking(bookingId)}/cancel',
      body: {'reason': reason},
    );
  }

  @override
  Future<void> completeBooking(String bookingId) async {
    await _api.post('${ApiEndpoints.booking(bookingId)}/complete');
  }
}

BookingRepository createBookingRepository() {
  if (AppConfig.useMockRepositories) return MockBookingRepository();
  return RemoteBookingRepository();
}
