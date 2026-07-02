import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/utils/api_parse.dart';
import 'package:travelmateeee/data/models/wallet_model.dart';

abstract class WalletRepository {
  Future<WalletModel> getWallet();
  Future<WalletModel> fundWallet({required double amount, required String method});
  Future<WalletFundingSession> initializeWalletFunding({
    required double amount,
  });
  Future<WalletModel> verifyWalletPayment({required String reference});
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
  Future<WalletModel> withdrawFunds({
    required double amount,
    required String bankAccount,
  });
  Future<List<Map<String, dynamic>>> getTransactions();
}

class WalletFundingSession {
  final String authorizationUrl;
  final String reference;

  const WalletFundingSession({
    required this.authorizationUrl,
    required this.reference,
  });

  bool get canLaunchCheckout => authorizationUrl.isNotEmpty;
}

class MockWalletRepository implements WalletRepository {
  WalletModel _wallet = WalletModel.mock();
  double _pendingFundingAmount = 0;

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
  Future<WalletFundingSession> initializeWalletFunding({
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _pendingFundingAmount = amount;
    return WalletFundingSession(
      authorizationUrl: 'https://checkout.paystack.com/mock-reference',
      reference: 'mock-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<WalletModel> verifyWalletPayment({required String reference}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _wallet = _wallet.copyWith(balance: _wallet.balance + _pendingFundingAmount);
    _pendingFundingAmount = 0;
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

  @override
  Future<WalletModel> withdrawFunds({
    required double amount,
    required String bankAccount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _wallet = _wallet.copyWith(balance: _wallet.balance - amount);
    return _wallet;
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        "id": "tx1",
        "title": "Wallet funding via card",
        "date": "Jun 12, 2026",
        "status": "completed",
        "amount": "+₦10,000",
        "type": "credit"
      },
      {
        "id": "tx2",
        "title": "Ride payment - Lagos to Ibadan",
        "date": "Jun 11, 2026",
        "status": "held",
        "amount": "₦5,000",
        "type": "debit"
      },
    ];
  }
}

class RemoteWalletRepository implements WalletRepository {
  RemoteWalletRepository();
  final ApiService _api = ApiService.instance;

  WalletModel _walletFromResponse(Map<String, dynamic> json) {
    return WalletModel.fromJson(
      ApiParse.asMap(json, keys: const ['wallet', 'data']),
    );
  }

  @override
  Future<WalletModel> getWallet() async {
    final json = await _api.get(ApiEndpoints.walletMe);
    return _walletFromResponse(json);
  }

  @override
  Future<WalletModel> fundWallet({
    required double amount,
    required String method,
  }) async {
    final json = await _api.post(
      ApiEndpoints.walletFund,
      body: {'amount': amount, 'paymentMethod': method},
    );
    return _walletFromResponse(json);
  }

  @override
  Future<WalletFundingSession> initializeWalletFunding({
    required double amount,
  }) async {
    final json = await _api.post(
      ApiEndpoints.walletFund,
      body: {'amount': amount, 'paymentMethod': 'paystack'},
    );
    final payload = ApiParse.asMap(json, keys: const ['data', 'payment']);
    final authorizationUrl =
        payload['authorization_url']?.toString() ??
        payload['authorizationUrl']?.toString() ??
        payload['paymentUrl']?.toString() ??
        payload['url']?.toString() ??
        '';
    final reference =
        payload['reference']?.toString() ??
        payload['paymentReference']?.toString() ??
        payload['access_code']?.toString() ??
        payload['accessCode']?.toString() ??
        '';
    if (authorizationUrl.isEmpty || reference.isEmpty) {
      throw ApiException(
        message: 'Payment initialization did not return a checkout URL.',
        statusCode: 0,
      );
    }
    return WalletFundingSession(
      authorizationUrl: authorizationUrl,
      reference: reference,
    );
  }

  @override
  Future<WalletModel> verifyWalletPayment({required String reference}) async {
    final json = await _api.post(
      ApiEndpoints.walletVerifyPayment,
      body: {'reference': reference},
    );
    return _walletFromResponse(json);
  }

  @override
  Future<WalletModel> buyAirtime({
    required String network,
    required String phone,
    required double amount,
  }) async {
    final json = await _api.post(
      ApiEndpoints.billsAirtime,
      body: {'network': network, 'phone': phone, 'amount': amount},
    );
    return _walletFromResponse(json);
  }

  @override
  Future<WalletModel> buyData({
    required String network,
    required String phone,
    required String planId,
    required double amount,
  }) async {
    final json = await _api.post(
      ApiEndpoints.billsData,
      body: {
        'network': network,
        'phone': phone,
        'plan_id': planId,
        'amount': amount,
      },
    );
    return _walletFromResponse(json);
  }

  @override
  Future<WalletModel> payBill({
    required String category,
    required String provider,
    required String accountNumber,
    required double amount,
  }) async {
    final json = await _api.post(
      ApiEndpoints.billsElectricity,
      body: {
        'category': category,
        'provider': provider,
        'account_number': accountNumber,
        'amount': amount,
      },
    );
    return _walletFromResponse(json);
  }

  @override
  Future<WalletModel> withdrawFunds({
    required double amount,
    required String bankAccount,
  }) async {
    final json = await _api.post(
      ApiEndpoints.walletWithdraw,
      body: {'amount': amount, 'bank_account': bankAccount},
    );
    return _walletFromResponse(json);
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final userId = _api.getUserId();
    if (userId == null) return [];
    try {
      final json = await _api.get(ApiEndpoints.walletTransactions(userId));
      final list = ApiParse.asList(json, keys: const ['transactions', 'data']);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {}
    return [];
  }
}

WalletRepository createWalletRepository() {
  if (AppConfig.useMockRepositories) return MockWalletRepository();
  return RemoteWalletRepository();
}
