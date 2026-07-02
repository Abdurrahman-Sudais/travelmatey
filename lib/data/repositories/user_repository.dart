import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/services/media_picker_service.dart';
import 'package:travelmateeee/data/models/user_model.dart';

/// Profile & avatar operations.
///
/// UI calls this — never call [ApiService] directly from widgets.
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
  RemoteUserRepository();
  final ApiService _api = ApiService.instance;

  @override
  Future<UserModel> getCurrentUser() async {
    final userId = _api.getUserId() ?? 'me';
    final json = await _api.get(ApiEndpoints.profile(userId));
    final data = json['profile'] as Map<String, dynamic>? ??
        json['data'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>? ??
        json;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<UserModel> updateAddress({
    required String street,
    required String city,
    required String state,
    required String lga,
  }) async {
    final userId = _api.getUserId() ?? 'me';
    final json = await _api.put(
      ApiEndpoints.profile(userId),
      body: {
        'street': street,
        'city': city,
        'state': state,
        'lga': lga,
      },
    );
    final data = json['profile'] as Map<String, dynamic>? ??
        json['data'] as Map<String, dynamic>? ??
        json;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<String> uploadAvatar(PickedMedia media) async {
    try {
      final userId = _api.getUserId() ?? 'me';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}${ApiEndpoints.profileAvatar(userId)}'),
      );
      final token = _api.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (kIsWeb && media.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          media.bytes!,
          filename: media.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', media.path));
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final json = jsonDecode(response.body);
      return json['data']?['url']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}

UserRepository createUserRepository() {
  if (AppConfig.useMockRepositories) return MockUserRepository();
  return RemoteUserRepository();
}
