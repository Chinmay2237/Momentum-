
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:painter/painter.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key}) : super(key: key);

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final PainterController _controller = PainterController();

  @override
  void initState() {
    super.initState();
    _controller.thickness = 5.0;
    _controller.backgroundColor = Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final Uint8List? imageBytes = await _controller.exportAsPNGBytes();
              if (imageBytes != null) {
                // TODO: Save the image as a note
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image saved to gallery')),
                );
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Painter(_controller),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () {
                    _controller.undo();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: () {
                    _controller.redo();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
