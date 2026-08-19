import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  static const String _cloudName = 'cnnsozts';
  static const String _uploadPreset = 'pd2morax';

  final CloudinaryPublic _cloudinary;

  StorageService({CloudinaryPublic? cloudinary})
      : _cloudinary = cloudinary ??
      CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  /// Uploads an image file to Cloudinary and returns the public HTTPS download URL.
  Future<String> uploadNoteImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'users/$uid/note_images',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Cloudinary upload error: $e');
    }
  }
}