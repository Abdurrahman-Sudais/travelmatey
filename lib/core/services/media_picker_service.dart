import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Local file picked by the user before upload to the backend.
class PickedMedia {
  final String path;
  final String name;
  final int sizeBytes;
  final bool isImage;

  const PickedMedia({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.isImage,
  });

  File get file => File(path);
}

/// Handles gallery / camera / file selection on-device.
///
/// BACKEND: After picking, call [KycRepository.uploadDocument] or
/// [UserRepository.updateAvatar] with [PickedMedia.file] — the repo sends
/// multipart/form-data to your API.
class MediaPickerService {
  MediaPickerService._();
  static final MediaPickerService instance = MediaPickerService._();

  static const int maxBytes = 5 * 1024 * 1024; // 5 MB

  final ImagePicker _imagePicker = ImagePicker();

  Future<PickedMedia?> pickImageFromGallery() async {
    final x = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    return _fromXFile(x, isImage: true);
  }

  Future<PickedMedia?> captureImageFromCamera() async {
    final x = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    return _fromXFile(x, isImage: true);
  }

  /// Opens a bottom sheet: Camera or Gallery.
  Future<PickedMedia?> pickImageWithChooser(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SourceSheet(
        onCamera: () => Navigator.pop(ctx, ImageSource.camera),
        onGallery: () => Navigator.pop(ctx, ImageSource.gallery),
      ),
    );
    if (source == null) return null;

    final x = await _imagePicker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    return _fromXFile(x, isImage: true);
  }

  /// JPG / PNG / PDF for KYC documents.
  Future<PickedMedia?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final f = result.files.single;
    if (f.path == null) return null;

    final file = File(f.path!);
    final size = await file.length();
    if (size > maxBytes) {
      throw MediaTooLargeException(size);
    }

    final ext = f.extension?.toLowerCase() ?? '';
    return PickedMedia(
      path: f.path!,
      name: f.name,
      sizeBytes: size,
      isImage: ext == 'jpg' || ext == 'jpeg' || ext == 'png',
    );
  }

  Future<PickedMedia?> _fromXFile(XFile? x, {required bool isImage}) async {
    if (x == null) return null;
    final file = File(x.path);
    final size = await file.length();
    if (size > maxBytes) throw MediaTooLargeException(size);

    return PickedMedia(
      path: x.path,
      name: x.name,
      sizeBytes: size,
      isImage: isImage,
    );
  }
}

class MediaTooLargeException implements Exception {
  final int bytes;
  MediaTooLargeException(this.bytes);
}

class _SourceSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _SourceSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: onGallery,
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: onCamera,
            ),
          ],
        ),
      ),
    );
  }
}
