import 'dart:io';

import 'package:travelmateeee/core/api/api_client.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/services/media_picker_service.dart';
import 'package:travelmateeee/data/models/user_model.dart';

/// Profile & avatar operations.
///
/// UI calls this — never call [ApiClient] directly from widgets.
abstract class UserRepository {
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateAddress({
    required String street,
    required String city,
    required String state,
    required String lga,
  });

  /// BACKEND: POST multipart to [ApiEndpoints.avatar], field name `file`.
  Future<String> uploadAvatar(PickedMedia media);
}

class MockUserRepository implements UserRepository {
  UserModel _user = UserModel.mock();

  @override
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _user;
  }

  @override
  Future<UserModel> updateAddress({
    required String street,
    required String city,
    required String state,
    required String lga,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _user = _user.copyWith(
      street: street,
      city: city,
      state: state,
      lga: lga,
    );
    return _user;
  }

  @override
  Future<String> uploadAvatar(PickedMedia media) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Local path stands in for CDN URL until backend is live.
    _user = _user.copyWith(avatarUrl: media.path);
    return media.path;
  }
}

class RemoteUserRepository implements UserRepository {
  RemoteUserRepository(this._api);
  final ApiClient _api;

  @override
  Future<UserModel> getCurrentUser() async {
    final json = await _api.get(ApiEndpoints.me);
    return UserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateAddress({
    required String street,
    required String city,
    required String state,
    required String lga,
  }) async {
    final json = await _api.put(
      ApiEndpoints.address,
      body: {'street': street, 'city': city, 'state': state, 'lga': lga},
    );
    return UserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<String> uploadAvatar(PickedMedia media) async {
    final json = await _api.postMultipart(
      ApiEndpoints.avatar,
      file: media.file,
      fileField: 'file',
    );
    return json['data']?['url']?.toString() ?? '';
  }
}

UserRepository createUserRepository(ApiClient api) {
  if (AppConfig.useMockRepositories) return MockUserRepository();
  return RemoteUserRepository(api);
}
