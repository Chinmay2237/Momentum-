
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:momentum/models/note.dart';
import 'package:momentum/services/note_service.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final NoteService _noteService = NoteService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  Color _currentColor = const Color(0xFFFFFFFF);
  int _contentCharCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _currentColor = Color(widget.note!.color);
    }
    _contentController.addListener(() {
      setState(() {
        _contentCharCount = _contentController.text.length;
      });
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final title = _titleController.text;
              final content = _contentController.text;

              if (title.isEmpty || content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter title and content')),
                );
                return;
              }

              if (widget.note == null) {
                await _noteService.createNote(title, content, color: _currentColor.value);
              } else {
                final updatedNote = Note(
                  id: widget.note!.id,
                  title: title,
                  content: content,
                  createdAt: widget.note!.createdAt,
                  color: _currentColor.value,
                );
                await _noteService.updateNote(updatedNote);
              }

              Navigator.of(context).pop();
            },
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _noteService.deleteNote(widget.note!.id!);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('$_contentCharCount characters'),
            ),
          ],
        ),
      ),
    );
  }
}
