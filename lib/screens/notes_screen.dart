import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../repositories/notes_repository.dart';
import '../services/auth_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  void _showNoteDialog({NoteModel? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final authService = context.read<AuthService>();
    final notesRepo = context.read<INotesRepository>();
    final uid = authService.currentUid;

    if (uid == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(note == null ? 'New Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isNotEmpty) {
                if (note == null) {
                  await notesRepo.addNote(
                    uid: uid,
                    title: title,
                    content: content,
                  );
                } else {
                  await notesRepo.updateNote(
                    uid: uid,
                    noteId: note.id,
                    title: title,
                    content: content,
                  );
                }
              }
              if (mounted) Navigator.pop(dialogContext);
            },
            child: Text(note == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(String noteId) async {
    final authService = context.read<AuthService>();
    final notesRepo = context.read<INotesRepository>();
    final uid = authService.currentUid;
    if (uid == null) return;
    await notesRepo.deleteNote(uid: uid, noteId: noteId);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final notesRepo = context.watch<INotesRepository>();
    final uid = authService.currentUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FireNotes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('No user logged in'))
          : StreamBuilder<List<NoteModel>>(
        stream: notesRepo.getNotes(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading notes: ${snapshot.error}'),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet. Tap + to add one!',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: notes.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _showNoteDialog(note: note),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteNote(note.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}