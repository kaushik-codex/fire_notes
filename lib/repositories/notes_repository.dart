import '../models/note_model.dart';
import '../services/notes_service.dart';

abstract class INotesRepository {
  Stream<List<NoteModel>> getNotes(String uid);
  Future<void> addNote({required String uid, required String title, required String content});
  Future<void> updateNote({required String uid, required String noteId, required String title, required String content});
  Future<void> deleteNote({required String uid, required String noteId});
}

class NotesRepository implements INotesRepository {
  final NotesService _notesService;

  NotesRepository({NotesService? notesService})
      : _notesService = notesService ?? NotesService();

  @override
  Stream<List<NoteModel>> getNotes(String uid) {
    return _notesService.streamNotes(uid);
  }

  @override
  Future<void> addNote({
    required String uid,
    required String title,
    required String content,
  }) async {
    await _notesService.createNote(
      uid: uid,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String title,
    required String content,
  }) async {
    await _notesService.updateNote(
      uid: uid,
      noteId: noteId,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> deleteNote({
    required String uid,
    required String noteId,
  }) async {
    await _notesService.deleteNote(uid: uid, noteId: noteId);
  }
}