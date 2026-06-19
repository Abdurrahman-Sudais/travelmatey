import 'dart:io';

import 'package:flutter/material.dart';
import 'package:travelmateeee/core/services/media_picker_service.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';

/// Tap-to-upload box with preview. Picks locally; backend upload is separate.
class DocumentUploadBox extends StatelessWidget {
  final PickedMedia? media;
  final VoidCallback onTap;
  final Color borderColor;
  final Color iconColor;
  final String idleLabel;
  final String uploadedLabel;

  const DocumentUploadBox({
    super.key,
    required this.media,
    required this.onTap,
    this.borderColor = kPrimaryBlue,
    this.iconColor = kPrimaryBlue,
    this.idleLabel = 'Tap to upload',
    this.uploadedLabel = 'File selected',
  });

  bool get hasMedia => media != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: kUploadBoxFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasMedia ? kPrimaryGreen : borderColor,
            width: hasMedia ? 1.5 : 1,
          ),
        ),
        child: hasMedia ? _preview() : _idle(),
      ),
    );
  }

  Widget _idle() {
    return Column(
      children: [
        Icon(Icons.upload_outlined, color: iconColor, size: 32),
        const SizedBox(height: 8),
        Text(
          idleLabel,
          style: TextStyle(
            color: iconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'JPG, PNG or PDF (max 5MB)',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _preview() {
    final m = media!;
    return Column(
      children: [
        if (m.isImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(m.path),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Icon(Icons.picture_as_pdf, color: kPrimaryGreen, size: 48),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: kPrimaryGreen, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                m.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kPrimaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          uploadedLabel,
          style: TextStyle(fontSize: 12, color: kTextSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap to replace',
          style: TextStyle(fontSize: 11, color: kTextHint),
        ),
      ],
    );
  }
}

/// Shows snackbar on oversize / picker errors.
Future<PickedMedia?> pickDocumentSafely(
  BuildContext context, {
  bool useCameraForFace = false,
}) async {
  try {
    if (useCameraForFace) {
      return await MediaPickerService.instance.pickImageWithChooser(context);
    }
    return await MediaPickerService.instance.pickDocument();
  } on MediaTooLargeException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File is too large. Maximum size is 5MB.')),
      );
    }
    return null;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick file: $e')),
      );
    }
    return null;
  }
}
