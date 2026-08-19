import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads an image file to users/{uid}/note_images/ and returns the public download URL.
  Future<String> uploadNoteImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('users/$uid/note_images/$fileName');

      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Storage upload error (${e.code}): ${e.message}');
    }
  }

  /// Deletes an image from Firebase Storage given its full HTTPS URL.
  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      // Ignore if file was already deleted or not found
      if (e.code != 'object-not-found') {
        throw Exception('Storage delete error (${e.code}): ${e.message}');
      }
    }
  }
}