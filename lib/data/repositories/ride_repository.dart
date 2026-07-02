import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/utils/api_parse.dart';
import 'package:travelmateeee/data/models/ride_model.dart';

abstract class RideRepository {
  Future<List<RideModel>> getRides();
  Future<List<RideModel>> searchRides({
    required String from,
    required String to,
    required String date,
    required int seats,
  });
  Future<RideModel> createRide(Map<String, dynamic> data);
  Future<void> updateRide(String rideId, Map<String, dynamic> data);
  Future<void> deleteRide(String rideId);
}

class MockRideRepository implements RideRepository {
  @override
  Future<List<RideModel>> getRides() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      RideModel.mock(),
      RideModel.mock().copyWith(
        id: 'ride_2',
        from: 'Abuja',
        to: 'Lagos',
        departureTime: 'Jun 4, 2026 at 09:00',
        pricePerSeat: 15000.0,
      ),
    ];
  }

  @override
  Future<List<RideModel>> searchRides({
    required String from,
    required String to,
    required String date,
    required int seats,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      RideModel.mock().copyWith(from: from, to: to, availableSeats: seats),
    ];
  }

  @override
  Future<RideModel> createRide(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return RideModel.mock();
  }

  @override
  Future<void> updateRide(String rideId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> deleteRide(String rideId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

class RemoteRideRepository implements RideRepository {
  final ApiService _api = ApiService.instance;

  @override
  Future<List<RideModel>> getRides() async {
    final response = await _api.get('/rides');
    final list = ApiParse.asList(response, keys: const ['rides', 'data']);
    return list
        .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RideModel>> searchRides({
    required String from,
    required String to,
    required String date,
    required int seats,
  }) async {
    final response = await _api.get('/rides/search', query: {
      'from': from,
      'to': to,
      'date': date,
      'seats': seats.toString(),
    });
    final list = ApiParse.asList(response, keys: const ['rides', 'data']);
    return list
        .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RideModel> createRide(Map<String, dynamic> data) async {
    final response = await _api.post('/rides', body: data);
    return RideModel.fromJson(ApiParse.asMap(response, keys: const ['ride', 'data']));
  }

  @override
  Future<void> updateRide(String rideId, Map<String, dynamic> data) async {
    await _api.put('/rides/$rideId', body: data);
  }

  @override
  Future<void> deleteRide(String rideId) async {
    await _api.delete('/rides/$rideId');
  }
}

RideRepository createRideRepository() {
  if (AppConfig.useMockRepositories) return MockRideRepository();
  return RemoteRideRepository();
}
