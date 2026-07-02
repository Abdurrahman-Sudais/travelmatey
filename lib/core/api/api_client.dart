import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:travelmateeee/core/config/app_config.dart';

/// Thin HTTP wrapper. Replace internals when wiring Dio/interceptors.
///
/// BACKEND integration checklist:
/// 1. Store JWT in secure storage after sign-in.
/// 2. Pass token via [setAuthToken].
/// 3. Implement refresh flow on 401 in [_handleResponse].
/// 4. Use [postMultipart] for avatar/KYC uploads.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _authToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  void setAuthToken(String? token) => _authToken = token;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: query);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final res = await _client
        .get(_uri(path, query), headers: _headers)
        .timeout(AppConfig.apiTimeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _client
        .post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
        .timeout(AppConfig.apiTimeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _client
        .put(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
        .timeout(AppConfig.apiTimeout);
    return _handleResponse(res);
  }

  /// Multipart upload for avatar / KYC documents.
  ///
  /// BACKEND: Expect `file` field + optional metadata fields in [fields].
  /// Response should include `{ "url": "https://..." }` or document id.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required File file,
    required String fileField,
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    request.headers['Accept'] = 'application/json';
    fields?.forEach((key, value) {
      request.fields[key] = value;
    });
    request.files.add(await http.MultipartFile.fromPath(fileField, file.path));

    final streamed = await request.send().timeout(AppConfig.apiTimeout);
    final res = await http.Response.fromStream(streamed);
    return _handleResponse(res);
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    final decoded = res.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

    // BACKEND: Standardize error shape: { "message": "...", "code": "..." }
    throw ApiException(
      statusCode: res.statusCode,
      message: decoded['message']?.toString() ?? 'Request failed',
      body: decoded,
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> body;

  ApiException({
    required this.statusCode,
    required this.message,
    this.body = const {},
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
