import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  void _showNoteDialog({NoteModel? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    File? selectedImage;
    bool isUploading = false;
    String statusMessage = '';

    final authService = context.read<AuthService>();
    final notesRepo = context.read<INotesRepository>();
    final uid = authService.currentUid;

    if (uid == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImage(ImageSource source) async {
            try {
              final pickedFile = await _picker.pickImage(
                source: source,
                imageQuality: 70,
              );
              if (pickedFile != null) {
                setDialogState(() {
                  selectedImage = File(pickedFile.path);
                });
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error picking image: $e')),
                );
              }
            }
          }

          return AlertDialog(
            title: Text(note == null ? 'New Note' : 'Edit Note'),
            content: SizedBox(
              width: double.maxFinite, // Fixes RenderIntrinsicWidth layout crash
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      enabled: !isUploading,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      enabled: !isUploading,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else if (note?.imageUrl != null && note!.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          note.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (isUploading) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            statusMessage,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () => pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                          TextButton.icon(
                            onPressed: () => pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();

                  if (title.isEmpty) return;

                  setDialogState(() {
                    isUploading = true;
                    statusMessage = selectedImage != null
                        ? 'Uploading image...'
                        : 'Saving note...';
                  });

                  try {
                    if (note == null) {
                      await notesRepo.addNote(
                        uid: uid,
                        title: title,
                        content: content,
                        imageFile: selectedImage,
                      );
                    } else {
                      await notesRepo.updateNote(
                        uid: uid,
                        noteId: note.id,
                        title: title,
                        content: content,
                        imageUrl: note.imageUrl,
                      );
                    }
                    if (mounted) Navigator.pop(dialogContext);
                  } catch (e) {
                    setDialogState(() {
                      isUploading = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save note: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(note == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteNote(NoteModel note) async {
    final authService = context.read<AuthService>();
    final notesRepo = context.read<INotesRepository>();
    final uid = authService.currentUid;
    if (uid == null) return;
    await notesRepo.deleteNote(uid: uid, note: note);
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
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.imageUrl != null && note.imageUrl!.isNotEmpty)
                      Image.network(
                        note.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                      ),
                    ListTile(
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
                        onPressed: () => _deleteNote(note),
                      ),
                    ),
                  ],
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