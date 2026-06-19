import 'package:get/get.dart';
import 'package:travelmateeee/core/api/api_client.dart';
import 'package:travelmateeee/data/repositories/kyc_repository.dart';
import 'package:travelmateeee/data/repositories/user_repository.dart';
import 'package:travelmateeee/data/repositories/wallet_repository.dart';

/// Registers shared services & repositories at app start.
///
/// BACKEND: Add AuthRepository, RideRepository, BookingRepository here as you
/// wire them up. Toggle mocks via [AppConfig.useMockRepositories].
class ServiceLocator {
  ServiceLocator._();

  static void init() {
    final api = ApiClient();
    Get.put<ApiClient>(api, permanent: true);
    Get.put<UserRepository>(createUserRepository(api), permanent: true);
    Get.put<KycRepository>(createKycRepository(api), permanent: true);
    Get.put<WalletRepository>(createWalletRepository(api), permanent: true);
  }
}
