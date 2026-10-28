import 'package:flutter/material.dart';

class SketchCanvasScreen extends StatefulWidget {
  const SketchCanvasScreen({super.key});

  @override
  State<SketchCanvasScreen> createState() => _SketchCanvasScreenState();
}

class _SketchCanvasScreenState extends State<SketchCanvasScreen> {
  final List<List<Offset>> _lines = [];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;

  void _clear() {
    setState(() => _lines.clear());
  }

  void _undo() {
    if (_lines.isNotEmpty) {
      setState(() => _lines.removeLast());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جسمانی خاکہ (باڈی ڈایاگرام نوٹس)'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo, tooltip: 'واپس لائیں'),
          IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clear, tooltip: 'صاف کریں'),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop('sketch_saved');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('خاکہ محفوظ ہو گیا')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Body Figure Outline
          Center(
            child: Opacity(
              opacity: 0.25,
              child: CustomPaint(
                size: const Size(260, 450),
                painter: BodySilhouettePainter(),
              ),
            ),
          ),
          // User Drawing Canvas
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _lines.add([details.localPosition]);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                if (_lines.isNotEmpty) {
                  _lines.last.add(details.localPosition);
                }
              });
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: DrawingPainter(lines: _lines, color: _selectedColor, strokeWidth: _strokeWidth),
            ),
          ),
          // Bottom Color / Pen Toolbar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildColorDot(Colors.red),
                    _buildColorDot(Colors.blue),
                    _buildColorDot(Colors.black),
                    _buildColorDot(Colors.green),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.line_weight),
                      onPressed: () {
                        setState(() {
                          _strokeWidth = _strokeWidth == 3.0 ? 6.0 : 3.0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color c) {
    final isSelected = _selectedColor == c;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = c),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white,
            width: isSelected ? 3 : 1.5,
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final Color color;
  final double strokeWidth;

  DrawingPainter({required this.lines, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final line in lines) {
      if (line.isEmpty) continue;
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class BodySilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(w / 2, h * 0.1), width: w * 0.22, height: h * 0.15), paint);
    // Neck
    canvas.drawLine(Offset(w * 0.45, h * 0.175), Offset(w * 0.45, h * 0.21), paint);
    canvas.drawLine(Offset(w * 0.55, h * 0.175), Offset(w * 0.55, h * 0.21), paint);
    // Shoulders
    canvas.drawLine(Offset(w * 0.2, h * 0.24), Offset(w * 0.8, h * 0.24), paint);
    // Chest / Torso
    canvas.drawLine(Offset(w * 0.25, h * 0.24), Offset(w * 0.3, h * 0.52), paint);
    canvas.drawLine(Offset(w * 0.75, h * 0.24), Offset(w * 0.7, h * 0.52), paint);
    // Waist
    canvas.drawLine(Offset(w * 0.3, h * 0.52), Offset(w * 0.7, h * 0.52), paint);
    // Legs
    canvas.drawLine(Offset(w * 0.3, h * 0.52), Offset(w * 0.32, h * 0.95), paint);
    canvas.drawLine(Offset(w * 0.7, h * 0.52), Offset(w * 0.68, h * 0.95), paint);
    canvas.drawLine(Offset(w * 0.5, h * 0.6), Offset(w * 0.45, h * 0.95), paint);
    canvas.drawLine(Offset(w * 0.5, h * 0.6), Offset(w * 0.55, h * 0.95), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

