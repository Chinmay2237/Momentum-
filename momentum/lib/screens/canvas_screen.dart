
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:painter/painter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key}) : super(key: key);

  @override
  _CanvasScreenState createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late PainterController _controller;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = PainterController();
    _controller.thickness = 5.0;
    _controller.drawColor = Colors.black;
  }

  void _saveDrawing() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/drawing.png');
      await file.writeAsBytes(pngBytes);
      await ImageGallerySaver.saveFile(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drawing saved to gallery!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving drawing: $e')),
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
      body: RepaintBoundary(
        key: _globalKey,
        child: Painter(_controller),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.drawColor = Colors.red;
              });
            },
            child: const Icon(Icons.circle, color: Colors.red),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.drawColor = Colors.green;
              });
            },
            child: const Icon(Icons.circle, color: Colors.green),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.drawColor = Colors.blue;
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
           FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.clear();
              });
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
