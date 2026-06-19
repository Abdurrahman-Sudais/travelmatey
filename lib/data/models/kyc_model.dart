enum KycDocumentType { identity, address, face }

enum KycStatus { notStarted, pending, submitted, approved, rejected }

class KycStatusModel {
  final KycStatus status;
  final String? rejectionReason;

  const KycStatusModel({required this.status, this.rejectionReason});

  factory KycStatusModel.pending() =>
      const KycStatusModel(status: KycStatus.pending);

  factory KycStatusModel.submitted() =>
      const KycStatusModel(status: KycStatus.submitted);

  factory KycStatusModel.fromJson(Map<String, dynamic> json) {
    final raw = json['status']?.toString() ?? 'not_started';
    return KycStatusModel(
      status: KycStatus.values.firstWhere(
        (e) => e.name == raw || e.name == _snakeToCamel(raw),
        orElse: () => KycStatus.notStarted,
      ),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }
}

String _snakeToCamel(String s) {
  final parts = s.split('_');
  if (parts.length == 1) return parts.first;
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

class KycDocumentUploadResult {
  final String documentId;
  final String localPath;
  final String? remoteUrl;

  const KycDocumentUploadResult({
    required this.documentId,
    required this.localPath,
    this.remoteUrl,
  });
}

/// Payload for `POST /kyc/submit` — document IDs returned from upload endpoints.
class KycSubmission {
  final String idType;
  final String idNumber;
  final String? identityDocumentId;
  final String documentType;
  final String utilityType;
  final String? addressDocumentId;
  final String? bankName;
  final String? accountNumber;
  final String? faceDocumentId;

  const KycSubmission({
    required this.idType,
    required this.idNumber,
    this.identityDocumentId,
    required this.documentType,
    required this.utilityType,
    this.addressDocumentId,
    this.bankName,
    this.accountNumber,
    this.faceDocumentId,
  });

  Map<String, dynamic> toJson() => {
        'id_type': idType,
        'id_number': idNumber,
        if (identityDocumentId != null) 'identity_document_id': identityDocumentId,
        'document_type': documentType,
        'utility_type': utilityType,
        if (addressDocumentId != null) 'address_document_id': addressDocumentId,
        if (bankName != null) 'bank_name': bankName,
        if (accountNumber != null) 'account_number': accountNumber,
        if (faceDocumentId != null) 'face_document_id': faceDocumentId,
      };
}
