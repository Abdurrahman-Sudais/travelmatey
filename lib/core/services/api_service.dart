import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/config/app_config.dart';

/// Central HTTP client — attaches auth token and persists session.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static String get baseUrl => AppConfig.baseUrl;
  static const Duration timeout = Duration(seconds: 30);

  /// WEB-ONLY dev workaround for CORS. Set from [main] when testing in Chrome.
  /// Prefer `flutter run -d android` or `--web-browser-flag "--disable-web-security"`.
  static bool useWebCorsProxy = false;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _pendingTokenKey = 'pending_auth_token';
  static const _pendingRefreshTokenKey = 'pending_refresh_token';
  static const _pendingUserIdKey = 'pending_user_id';
  static const _pendingPhoneKey = 'pending_phone';
  static const _pendingEmailKey = 'pending_email';

  SharedPreferences? _prefs;
  final _secureStorage = const FlutterSecureStorage();
  
  String? _token;
  String? _refreshToken;
  String? _userId;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = await _secureStorage.read(key: _tokenKey);
    _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    _userId = await _secureStorage.read(key: _userIdKey);
  }

  Future<void> saveSession({
    required String token,
    required String refreshToken,
    required String userId,
  }) async {
    _token = token;
    _refreshToken = refreshToken;
    _userId = userId;
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  void setTemporarySession({
    required String token,
    required String refreshToken,
    required String userId,
  }) {
    _token = token;
    _refreshToken = refreshToken;
    _userId = userId;
  }

  Future<void> saveTemporarySession({
    required String token,
    required String refreshToken,
    required String userId,
    required String phone,
    required String email,
  }) async {
    setTemporarySession(
      token: token,
      refreshToken: refreshToken,
      userId: userId,
    );
    await _secureStorage.write(key: _pendingTokenKey, value: token);
    await _secureStorage.write(key: _pendingRefreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _pendingUserIdKey, value: userId);
    await _prefs?.setString(_pendingPhoneKey, phone);
    await _prefs?.setString(_pendingEmailKey, email);
  }

  Future<void> clearTemporarySession() async {
    await _secureStorage.delete(key: _pendingTokenKey);
    await _secureStorage.delete(key: _pendingRefreshTokenKey);
    await _secureStorage.delete(key: _pendingUserIdKey);
    await _prefs?.remove(_pendingPhoneKey);
    await _prefs?.remove(_pendingEmailKey);
  }

  Future<String?> getPendingToken() => _secureStorage.read(key: _pendingTokenKey);

  Future<String?> getPendingRefreshToken() => _secureStorage.read(key: _pendingRefreshTokenKey);

  Future<String?> getPendingUserId() => _secureStorage.read(key: _pendingUserIdKey);

  String? getPendingPhone() => _prefs?.getString(_pendingPhoneKey);

  String? getPendingEmail() => _prefs?.getString(_pendingEmailKey);

  String? getToken() => _token;

  Future<void> clearSession() async {
    _token = null;
    _refreshToken = null;
    _userId = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await clearTemporarySession();
  }

  String? getUserId() => _userId;

  String? getRefreshToken() => _refreshToken;

  bool isLoggedIn() => _token != null && _token!.isNotEmpty;

  Map<String, String> _headers({bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  String get _effectiveBaseUrl {
    if (kIsWeb && useWebCorsProxy) {
      // Public CORS proxy for local web testing only — do not use in production.
      return 'https://corsproxy.io/?${Uri.encodeComponent(baseUrl)}';
    }
    return baseUrl;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '$_effectiveBaseUrl$normalizedPath',
    ).replace(queryParameters: query);
  }

  Future<http.Response> _requestWithRetry(Future<http.Response> Function() requestFn) async {
    try {
      http.Response res = await requestFn();
      
      if (res.statusCode == 401 && _refreshToken != null) {
        final refreshSuccess = await _attemptTokenRefresh();
        if (refreshSuccess) {
          res = await requestFn();
        } else {
          await clearSession();
          Get.offAllNamed('/signin');
        }
      }
      return res;
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on TimeoutException {
      throw ApiException(message: 'Request timed out. Server may be waking up, please try again', statusCode: 0);
    } on FormatException {
      throw ApiException(message: 'Server error, please try again', statusCode: 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred', statusCode: 0);
    }
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final res = await http.post(
        _uri('/auth/refresh'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      ).timeout(timeout);
      
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final newToken = data['token'] ?? data['data']?['token'];
        if (newToken != null) {
          _token = newToken;
          await _secureStorage.write(key: _tokenKey, value: newToken);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final res = await _requestWithRetry(() => http.get(_uri(path, query), headers: _headers()).timeout(timeout));
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _requestWithRetry(() => http.post(_uri(path), headers: _headers(), body: jsonEncode(body ?? {})).timeout(timeout));
    return _handleResponse(res);
  }

  /// Like [post] but also returns the HTTP status (e.g. 200 vs 201).
  Future<ApiResult> postWithStatus(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _requestWithRetry(() => http.post(_uri(path), headers: _headers(), body: jsonEncode(body ?? {})).timeout(timeout));
    return ApiResult(
      statusCode: res.statusCode,
      body: _handleResponse(res, skipThrow: true),
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _requestWithRetry(() => http.put(_uri(path), headers: _headers(), body: jsonEncode(body ?? {})).timeout(timeout));
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _requestWithRetry(() async {
      final request = http.Request('DELETE', _uri(path));
      request.headers.addAll(_headers());
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamed = await http.Client().send(request).timeout(timeout);
      return http.Response.fromStream(streamed);
    });
    return _handleResponse(res);
  }

  Map<String, dynamic> _handleResponse(http.Response res, {bool skipThrow = false}) {
    final body = res.body;
    final contentType = res.headers['content-type'] ?? '';

    if (body.isEmpty) {
      if (res.statusCode >= 200 && res.statusCode < 300) return {};
      if (skipThrow) return {};
      throw ApiException(
        message: 'Server error (${res.statusCode})',
        statusCode: res.statusCode,
      );
    }

    final trimmed = body.trimLeft();
    final isJsonContentType = contentType.contains('application/json');
    final looksLikeHtml = trimmed.startsWith('<') || trimmed.startsWith('<!');

    if (!isJsonContentType && looksLikeHtml) {
      if (skipThrow) return {};
      throw ApiException(
        message: 'Server error (${res.statusCode})',
        statusCode: res.statusCode,
      );
    }

    Map<String, dynamic> decoded;
    try {
      final raw = jsonDecode(body);
      if (raw is Map<String, dynamic>) {
        decoded = raw;
      } else {
        decoded = {'data': raw};
      }
    } catch (_) {
      if (skipThrow) return {};
      throw ApiException(
        message: 'Server error (${res.statusCode})',
        statusCode: res.statusCode,
      );
    }

    if (res.statusCode >= 200 && res.statusCode < 300 || skipThrow) {
      return decoded;
    }

    throw ApiException(
      message:
          decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          'Server error (${res.statusCode})',
      statusCode: res.statusCode,
    );
  }
}

class ApiResult {
  final int statusCode;
  final Map<String, dynamic> body;

  const ApiResult({required this.statusCode, required this.body});
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
