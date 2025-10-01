import 'package:flutter/material.dart';

class NoteViewScreen extends StatelessWidget {
  final Map<String, dynamic> note;

  const NoteViewScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(note['content']),
      ),
    );
  }
}
