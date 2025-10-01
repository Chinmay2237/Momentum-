
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:painter/painter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key}) : super(key: key);

  @override
  _CanvasScreenState createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late PainterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PainterController(
      settings: PainterSettings(
        freeStyle: const FreeStyleSettings(
          color: Colors.black,
          strokeWidth: 5,
        ),
      ),
    );
  }

  void _saveDrawing() async {
    final Uint8List? data = await _controller.exportAsPNGBytes();
    if (data != null) {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/drawing.png');
      await file.writeAsBytes(data);
      await ImageGallerySaver.saveFile(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drawing saved to gallery!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Painter(_controller),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.freeStyleColor = Colors.red;
              });
            },
            child: const Icon(Icons.circle, color: Colors.red),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.freeStyleColor = Colors.green;
              });
            },
            child: const Icon(Icons.circle, color: Colors.green),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.freeStyleColor = Colors.blue;
              });
            },
            child: const Icon(Icons.circle, color: Colors.blue),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.undo();
              });
            },
            child: const Icon(Icons.undo),
          ),
        ],
      ),
    );
  }
}
