import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:travelmateeee/core/services/api_service.dart';
import 'package:travelmateeee/core/api/api_endpoints.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/services/media_picker_service.dart';
import 'package:travelmateeee/data/models/kyc_model.dart';

/// KYC document upload & submission.
abstract class KycRepository {
  Future<KycStatusModel> getStatus();
  Future<KycDocumentUploadResult> uploadDocument({
    required KycDocumentType type,
    required PickedMedia media,
    Map<String, String>? metadata,
  });
  Future<KycStatusModel> submitKyc(KycSubmission submission);
}

class MockKycRepository implements KycRepository {
  KycStatusModel _status = KycStatusModel.pending();

  @override
  Future<KycStatusModel> getStatus() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _status;
  }

  @override
  Future<KycDocumentUploadResult> uploadDocument({
    required KycDocumentType type,
    required PickedMedia media,
    Map<String, String>? metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return KycDocumentUploadResult(
      documentId: 'mock_${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      localPath: media.path,
    );
  }

  @override
  Future<KycStatusModel> submitKyc(KycSubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _status = KycStatusModel.submitted();
    return _status;
  }
}

class RemoteKycRepository implements KycRepository {
  RemoteKycRepository();
  final ApiService _api = ApiService.instance;

  @override
  Future<KycStatusModel> getStatus() async {
    final json = await _api.get(ApiEndpoints.kycStatus);
    return KycStatusModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<KycDocumentUploadResult> uploadDocument({
    required KycDocumentType type,
    required PickedMedia media,
    Map<String, String>? metadata,
  }) async {
    final fields = {
      'type': type.name,
      ...?metadata,
    };
    
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}${ApiEndpoints.kycDocument}'));
      final token = _api.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      fields.forEach((key, value) {
        request.fields[key] = value;
      });
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
      final data = json['data'] as Map<String, dynamic>;
      
      return KycDocumentUploadResult(
        documentId: data['id']?.toString() ?? '',
        localPath: media.path,
        remoteUrl: data['url']?.toString(),
      );
    } catch (e) {
      throw Exception('Failed to upload KYC document: $e');
    }
  }

  @override
  Future<KycStatusModel> submitKyc(KycSubmission submission) async {
    final json = await _api.post(
      ApiEndpoints.kycSubmit,
      body: submission.toJson(),
    );
    return KycStatusModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}

KycRepository createKycRepository() {
  if (AppConfig.useMockRepositories) return MockKycRepository();
  return RemoteKycRepository();
}
