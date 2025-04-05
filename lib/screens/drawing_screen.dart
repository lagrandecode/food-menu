import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import '../widgets/time.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawingPoint?> points = [];
  List<List<DrawingPoint?>> history = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;
  bool isEraser = false;
  String marqueeText = "Caribbean Queen Jerk is the premier restaurant for delicious, authentic, and affordable Jamaican cuisine in the Greater Toronto Area. We are proud to serve you great food across five locations, including our special Caribbean buffet. Our leadership team has spent more than a decade working together to build a delicious menu and a positive customer experience. Our food is fresh and our smiles are free. Our doors open at 6:00 am to welcome hundreds of hungry clients for breakfast, and they don't close until everyone has enjoyed their tasty Caribbean lunches and dinners. We look forward to serving you soon.";

  void addPoint(Offset? offset) {
    setState(() {
      points.add(
        offset == null ? null : DrawingPoint(
          offset: offset,
          paint: Paint()
            ..color = isEraser ? Colors.white : selectedColor
            ..isAntiAlias = true
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
        ),
      );
    });
  }

  void clear() {
    setState(() {
      history.add(List.from(points));
      points.clear();
    });
  }

  void undo() {
    if (history.isNotEmpty) {
      setState(() {
        points = history.removeLast();
      });
    }
  }

  void changeColor(Color color) {
    setState(() {
      selectedColor = color;
      isEraser = false;
    });
  }

  void toggleEraser() {
    setState(() {
      isEraser = !isEraser;
    });
  }

  void changeStrokeWidth(double width) {
    setState(() {
      strokeWidth = width;
    });
  }

  Future<void> _saveDrawing() async {
    try {
      final boundary = context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final status = await Permission.storage.request();
      if (status.isGranted) {
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 100,
          name: "drawing_${DateTime.now().millisecondsSinceEpoch}.png",
        );
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Drawing saved successfully!',
                style: GoogleFonts.spaceGrotesk(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save drawing: $e',
            style: GoogleFonts.spaceGrotesk(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Drawing Board',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: clear,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            color: Colors.grey[900],
            child: Marquee(
              text: marqueeText,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 20.0,
              velocity: 50.0,
              startPadding: 10.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Time(),
                const SizedBox(height: 24),
                Text(
                  'Drawing Board',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Draw anything you want',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.grey[400],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                RepaintBoundary(
                  child: GestureDetector(
                    onPanStart: (details) {
                      addPoint(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      addPoint(details.localPosition);
                    },
                    onPanEnd: (details) {
                      addPoint(null);
                    },
                    child: CustomPaint(
                      painter: _DrawingPainter(points),
                      size: Size.infinite,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildColorButton(Colors.black),
                        _buildColorButton(Colors.red),
                        _buildColorButton(Colors.green),
                        _buildColorButton(Colors.blue),
                        _buildColorButton(Colors.yellow),
                        IconButton(
                          icon: Icon(
                            Icons.brush,
                            color: isEraser ? Colors.white : Colors.grey,
                          ),
                          onPressed: toggleEraser,
                        ),
                        Expanded(
                          child: Slider(
                            value: strokeWidth,
                            min: 1,
                            max: 10,
                            onChanged: changeStrokeWidth,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => changeColor(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({
    required this.offset,
    required this.paint,
  });
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  _DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 