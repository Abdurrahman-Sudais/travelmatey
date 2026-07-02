import 'package:get/get.dart';
import 'package:travelmateeee/core/api/api_client.dart';
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/services/auth_service.dart';
import 'package:travelmateeee/data/repositories/kyc_repository.dart';
import 'package:travelmateeee/data/repositories/user_repository.dart';
import 'package:travelmateeee/data/repositories/wallet_repository.dart';
import 'package:travelmateeee/data/repositories/chat_repository.dart';

/// Registers shared services & repositories at app start.
class ServiceLocator {
  ServiceLocator._();

  static Future<void> init() async {
    await ApiService.instance.init();
    Get.put<ApiService>(ApiService.instance, permanent: true);
    Get.put<AuthService>(AuthService.instance, permanent: true);

    final api = ApiClient();
    Get.put<ApiClient>(api, permanent: true);
    Get.put<UserRepository>(createUserRepository(), permanent: true);
    Get.put<KycRepository>(createKycRepository(), permanent: true);
    Get.put<WalletRepository>(createWalletRepository(), permanent: true);
    Get.put<ChatRepository>(createChatRepository(), permanent: true);
  }
}
