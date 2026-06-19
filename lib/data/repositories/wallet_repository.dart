import 'package:travelmateeee/core/api/api_client.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/data/models/wallet_model.dart';

abstract class WalletRepository {
  Future<WalletModel> getWallet();
  Future<WalletModel> fundWallet({required double amount, required String method});
  Future<WalletModel> buyAirtime({
    required String network,
    required String phone,
    required double amount,
  });
  Future<WalletModel> buyData({
    required String network,
    required String phone,
    required String planId,
    required double amount,
  });
  Future<WalletModel> payBill({
    required String category,
    required String provider,
    required String accountNumber,
    required double amount,
  });
}

class MockWalletRepository implements WalletRepository {
  WalletModel _wallet = WalletModel.mock();

  @override
  Future<WalletModel> getWallet() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _wallet;
  }

  @override
  Future<WalletModel> fundWallet({
    required double amount,
    required String method,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _wallet = _wallet.copyWith(balance: _wallet.balance + amount);
    return _wallet;
  }

  @override
  Future<WalletModel> buyAirtime({
    required String network,
    required String phone,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _wallet = _wallet.copyWith(balance: _wallet.balance - amount);
    return _wallet;
  }

  @override
  Future<WalletModel> buyData({
    required String network,
    required String phone,
    required String planId,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _wallet = _wallet.copyWith(balance: _wallet.balance - amount);
    return _wallet;
  }

  @override
  Future<WalletModel> payBill({
    required String category,
    required String provider,
    required String accountNumber,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _wallet = _wallet.copyWith(balance: _wallet.balance - amount);
    return _wallet;
  }
}

class RemoteWalletRepository implements WalletRepository {
  RemoteWalletRepository(this._api);
  final ApiClient _api;

  @override
  Future<WalletModel> getWallet() async {
    final json = await _api.get(ApiEndpoints.wallet);
    return WalletModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<WalletModel> fundWallet({
    required double amount,
    required String method,
  }) async {
    final json = await _api.post(
      ApiEndpoints.walletFund,
      body: {'amount': amount, 'method': method},
    );
    return WalletModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<WalletModel> buyAirtime({
    required String network,
    required String phone,
    required double amount,
  }) async {
    final json = await _api.post(
      ApiEndpoints.walletAirtime,
      body: {'network': network, 'phone': phone, 'amount': amount},
    );
    return WalletModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<WalletModel> buyData({
    required String network,
    required String phone,
    required String planId,
    required double amount,
  }) async {
    final json = await _api.post(
      ApiEndpoints.walletData,
      body: {
        'network': network,
        'phone': phone,
        'plan_id': planId,
        'amount': amount,
      },
    );
    return WalletModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<WalletModel> payBill({
    required String category,
    required String provider,
    required String accountNumber,
    required double amount,
  }) async {
    final json = await _api.post(
      ApiEndpoints.walletBills,
      body: {
        'category': category,
        'provider': provider,
        'account_number': accountNumber,
        'amount': amount,
      },
    );
    return WalletModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}

WalletRepository createWalletRepository(ApiClient api) {
  if (AppConfig.useMockRepositories) return MockWalletRepository();
  return RemoteWalletRepository(api);
}
