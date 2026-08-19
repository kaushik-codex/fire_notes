import 'dart:io';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import '../services/storage_service.dart';

abstract class INotesRepository {
  Stream<List<NoteModel>> getNotes(String uid);
  Future<void> addNote({
    required String uid,
    required String title,
    required String content,
    File? imageFile,
  });
  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String title,
    required String content,
    String? imageUrl,
  });
  Future<void> deleteNote({
    required String uid,
    required NoteModel note,
  });
}

class NotesRepository implements INotesRepository {
  final NotesService _notesService;
  final StorageService _storageService;

  NotesRepository({
    NotesService? notesService,
    StorageService? storageService,
  })  : _notesService = notesService ?? NotesService(),
        _storageService = storageService ?? StorageService();

  @override
  Stream<List<NoteModel>> getNotes(String uid) {
    return _notesService.streamNotes(uid);
  }

  @override
  Future<void> addNote({
    required String uid,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _storageService.uploadNoteImage(
        uid: uid,
        imageFile: imageFile,
      );
    }

    await _notesService.createNote(
      uid: uid,
      title: title,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    await _notesService.updateNote(
      uid: uid,
      noteId: noteId,
      title: title,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> deleteNote({
    required String uid,
    required NoteModel note,
  }) async {
    if (note.imageUrl != null && note.imageUrl!.isNotEmpty) {
      await _storageService.deleteImageByUrl(note.imageUrl!);
    }
    await _notesService.deleteNote(uid: uid, noteId: note.id);
  }
}