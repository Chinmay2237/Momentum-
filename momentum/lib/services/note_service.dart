
import 'package:momentum/models/note.dart';
import 'package:momentum/services/database_helper.dart';

class NoteService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> createNote(String title, String content, {int? color}) async {
    final note = Note(
      title: title,
      content: content,
      createdAt: DateTime.now(),
      color: color ?? 0xFFFFFFFF, // Default to white if no color is provided
    );
    return await _db.createNote(note);
  }

  Future<List<Note>> getNotes() async {
    return await _db.getNotes();
  }

  Future<int> updateNote(Note note) async {
    return await _db.updateNote(note);
  }

  Future<int> deleteNote(int id) async {
    return await _db.deleteNote(id);
  }
}
