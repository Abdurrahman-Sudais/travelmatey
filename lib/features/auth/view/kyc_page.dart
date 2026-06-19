import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/services/media_picker_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/data/models/kyc_model.dart';
import 'package:travelmateeee/data/repositories/kyc_repository.dart';
import 'package:travelmateeee/shared/widgets/document_upload_box.dart';
import 'package:travelmateeee/shared/widgets/keyboard_aware_scaffold.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  int _step = 0; // 0-3

  // Step 1 - Identity
  final _idTypeCtrl = TextEditingController();
  final _idNumberCtrl = TextEditingController();
  PickedMedia? _idDocument;
  String? _identityDocumentId;

  // Step 2 - Address
  final _docTypeCtrl = TextEditingController();
  String _utilityType = 'Electricity';
  PickedMedia? _addressDocument;
  String? _addressDocumentId;

  // Step 3 - Banking
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  bool _accountVerified = false;

  // Step 4 - Face
  PickedMedia? _faceDocument;
  String? _faceDocumentId;

  bool _submitting = false;

  KycRepository get _kycRepo => Get.find<KycRepository>();

  @override
  void dispose() {
    _idTypeCtrl.dispose();
    _idNumberCtrl.dispose();
    _docTypeCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(KycDocumentType type) async {
    final useCamera = type == KycDocumentType.face;
    final media = await pickDocumentSafely(context, useCameraForFace: useCamera);
    if (media == null || !mounted) return;

    setState(() => _submitting = true);
    try {
      // BACKEND: POST /kyc/documents multipart — returns document id
      final result = await _kycRepo.uploadDocument(
        type: type,
        media: media,
        metadata: type == KycDocumentType.identity
            ? {'id_type': _idTypeCtrl.text, 'id_number': _idNumberCtrl.text}
            : null,
      );
      setState(() {
        switch (type) {
          case KycDocumentType.identity:
            _idDocument = media;
            _identityDocumentId = result.documentId;
          case KycDocumentType.address:
            _addressDocument = media;
            _addressDocumentId = result.documentId;
          case KycDocumentType.face:
            _faceDocument = media;
            _faceDocumentId = result.documentId;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitKyc() async {
    setState(() => _submitting = true);
    try {
      await _kycRepo.submitKyc(
        KycSubmission(
          idType: _idTypeCtrl.text,
          idNumber: _idNumberCtrl.text,
          identityDocumentId: _identityDocumentId,
          documentType: _docTypeCtrl.text,
          utilityType: _utilityType,
          addressDocumentId: _addressDocumentId,
          bankName: _bankNameCtrl.text.isEmpty ? null : _bankNameCtrl.text,
          accountNumber:
              _accountNumberCtrl.text.isEmpty ? null : _accountNumberCtrl.text,
          faceDocumentId: _faceDocumentId,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('KYC submission failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _next() {
    if (_step < 3) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Identity Verification',
      'Proof of Address',
      'Banking Details',
      'Face Verification',
    ];
    final subtitles = [
      'Verify your identity with a valid ID',
      'Confirm your residential address',
      'Add your bank account for payouts (optional)',
      'Upload a face image for verification',
    ];

    return KeyboardAwareFormScaffold(
      showSos: false,
      backgroundColor: kBackground,
      bottomBar: _bottomButton(),
      body: KeyboardAwareScrollBody(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
                    // Back
                    GestureDetector(
                      onTap: _back,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 20, color: kTextPrimary),
                          const SizedBox(width: 4),
                          Text('Back',
                              style: TextStyle(
                                  fontSize: 15, color: kTextPrimary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      titles[_step],
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitles[_step],
                      style: TextStyle(
                        fontSize: 14,
                        color: kTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    Row(
                      children: List.generate(4, (i) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _step
                                  ? kPrimaryBlue
                                  : kDivider,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step ${_step + 1} of 4',
                          style: TextStyle(
                            fontSize: 12,
                            color: kTextSecondary,
                          ),
                        ),
                        const Text(
                          '0 completed',
                          style: TextStyle(fontSize: 12, color: kPrimaryGreen),
                        ),
                      ],
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.08, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_step),
                        child: _step == 0
                            ? _buildStep1()
                            : _step == 1
                                ? _buildStep2()
                                : _step == 2
                                    ? _buildStep3()
                                    : _buildStep4(),
                      ),
                    ),
        ],
      ),
    );
  }

  // ── Step 1: Identity ──────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          icon: Icons.description_outlined,
          iconBg: const Color(0xFFE8F0FE),
          iconColor: kPrimaryBlue,
          title: 'Valid Identification',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('ID Type *'),
              _dropdownField(
                _idTypeCtrl,
                hint: '',
                options: [
                  'NIN',
                  'Passport',
                  "Driver's License",
                  "Voter's Card",
                ],
              ), // Fixed syntax error here
              const SizedBox(height: 16),
              _label('ID Number *'),
              _textField(
                _idNumberCtrl,
                hint: 'Enter your ID number',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _label('Upload ID Document *'),
              DocumentUploadBox(
                media: _idDocument,
                onTap: () => _pickDocument(KycDocumentType.identity),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _infoBox(
          color: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
          icon: Icons.check_circle_outline,
          iconColor: kPrimaryGreen,
          title: 'Your documents are secure',
          body: 'All uploaded documents are encrypted and stored securely.',
        ),
      ],
    );
  }

  // ── Step 2: Address ───────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          icon: Icons.location_on_outlined,
          iconBg: const Color(0xFFE8F5E9),
          iconColor: kPrimaryGreen,
          title: 'Address Verification',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Document Type *'),
              _dropdownField(
                _docTypeCtrl,
                hint: '',
                options: [
                  'Utility Bill',
                  'Bank Statement',
                  'Tenancy Agreement',
                ],
              ),
              const SizedBox(height: 16),
              _label('Utility Type *'),
              Row(
                children: ['Electricity', 'Water'].map((type) {
                  final selected = _utilityType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _utilityType = type),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: type == 'Electricity' ? 10 : 0,
                        ),
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? kPrimaryBlue : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _label('Upload Document *'),
              DocumentUploadBox(
                media: _addressDocument,
                onTap: () => _pickDocument(KycDocumentType.address),
                borderColor: kPrimaryGreen,
                iconColor: kPrimaryGreen,
              ),
              const SizedBox(height: 6),
              const Text(
                'Document must be dated within the last 3 months',
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _infoBox(
          color: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
          icon: Icons.info_outline,
          iconColor: kAmber,
          title: 'Document Requirements',
          body:
              'Your address on this document must match your registered address.',
        ),
      ],
    );
  }

  // ── Step 3: Banking ───────────────────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          color: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
          icon: Icons.info_outline,
          iconColor: kAmber,
          title: '',
          body:
              'Bank verification is optional. You can add this later from your profile settings.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF3E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.credit_card, color: kAmber),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Bank Account',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Optional',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _label('Bank Name *'),
              _dropdownField(
                _bankNameCtrl,
                hint: '',
                options: [
                  'Access Bank',
                  'GTBank',
                  'First Bank',
                  'Zenith Bank',
                  'UBA',
                ],
              ),
              const SizedBox(height: 16),
              _label('Account Number *'),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      _accountNumberCtrl,
                      hint: '0123456789',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (_accountNumberCtrl.text.length >= 10) {
                        setState(() => _accountVerified = true);
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _accountNumberCtrl.text.isNotEmpty
                            ? kPrimaryBlue
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          color: _accountNumberCtrl.text.isNotEmpty
                              ? Colors.white
                              : Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_accountVerified) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPrimaryGreen),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: kPrimaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Verified',
                            style: TextStyle(
                              fontSize: 12,
                              color: kPrimaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'AMINA HASSAN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _infoBox(
          color: const Color(0xFFE8F0FE),
          borderColor: const Color(0xFFBBD4FB),
          icon: Icons.credit_card,
          iconColor: kPrimaryBlue,
          title: 'Secure Payouts',
          body:
              'This account will be used for receiving ride payments and withdrawals.',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: kPrimaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Powered by NUBAPI · Real-time bank verification',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 4: Face ──────────────────────────────────────────────────────────
  Widget _buildStep4() {
    final captured = _faceDocument != null;
    return Column(
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              gradient: kPrimaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Face Verification',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Take a clear photo of your face for identity verification',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: kTextSecondary),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kUploadBoxFill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: kSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: captured ? kPrimaryGreen : kPrimaryBlue,
                    width: 2.5,
                  ),
                  image: captured && _faceDocument!.isImage
                      ? DecorationImage(
                          image: FileImage(File(_faceDocument!.path)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !captured || !_faceDocument!.isImage
                    ? Icon(
                        captured ? Icons.face : Icons.camera_alt_outlined,
                        color: captured ? kPrimaryGreen : kPrimaryBlue,
                        size: 40,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                captured ? 'Face Captured' : 'Ready to Capture',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                captured
                    ? 'Your face image has been captured successfully'
                    : 'Position your face in the center and ensure good lighting',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kTextSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kDivider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verification Guidelines:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: _GuidelineItem(label: 'Face clearly visible'),
                  ),
                  Expanded(child: _GuidelineItem(label: 'Good lighting')),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _GuidelineItem(label: 'Remove glasses')),
                  Expanded(child: _GuidelineItem(label: 'Look at camera')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _submitting ? null : () => _pickDocument(KycDocumentType.face),
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Start Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Skip for now (Complete later in Profile)',
            style: TextStyle(
              fontSize: 13,
              decoration: TextDecoration.underline,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────
  Widget _card({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl, {
    String hint = '',
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryBlue),
        ),
      ),
    );
  }

  Widget _dropdownField(
    TextEditingController ctrl, {
    String hint = '',
    required List<String> options,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: ctrl.text.isEmpty ? null : ctrl.text,
      hint: Text(hint, style: const TextStyle(color: Colors.black38)),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) => setState(() => ctrl.text = v ?? ''),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _infoBox({
    required Color color,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                if (title.isNotEmpty) const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    final isLastStep = _step == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: GestureDetector(
        onTap: _submitting
            ? null
            : (isLastStep ? _submitKyc : _next),
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: _submitting ? null : kPrimaryGradient,
            color: _submitting ? kDivider : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isLastStep ? 'Submit KYC' : 'Save and Continue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final String label;
  const _GuidelineItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check, color: kPrimaryGreen, size: 15),
        const SizedBox(width: 6),
        Flexible(child: Text(label, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}
