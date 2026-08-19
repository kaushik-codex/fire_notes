import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class NotesService {
  final FirebaseFirestore _firestore;

  NotesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Private helper to get the reference to a specific user's notes collection.
  CollectionReference<Map<String, dynamic>> _userNotesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  /// Streams real-time updates for all notes belonging to a specific user.
  Stream<List<NoteModel>> streamNotes(String uid) {
    return _userNotesRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NoteModel.fromFirestore(doc))
        .toList());
  }

  /// Creates a new note under users/{uid}/notes.
  Future<void> createNote({
    required String uid,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    final noteData = {
      'title': title,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _userNotesRef(uid).add(noteData);
  }

  /// Updates an existing note under users/{uid}/notes/{noteId}.
  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    final noteData = {
      'title': title,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _userNotesRef(uid).doc(noteId).update(noteData);
  }

  /// Deletes a note under users/{uid}/notes/{noteId}.
  Future<void> deleteNote({
    required String uid,
    required String noteId,
  }) async {
    await _userNotesRef(uid).doc(noteId).delete();
  }
}