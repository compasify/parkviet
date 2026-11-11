import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;

import 'print_commands.dart';

/// Draws one line of text as a black-on-white image the width of the paper,
/// for printers that cannot print Vietnamese letters as text.
abstract interface class TextRasterizer {
  Future<img.Image> rasterize(TextCommand line, {required int widthDots, required int columns});
}

/// Uses the platform's text engine, so every Vietnamese letter prints.
class FlutterTextRasterizer implements TextRasterizer {
  const FlutterTextRasterizer();

  @override
  Future<img.Image> rasterize(TextCommand line, {required int widthDots, required int columns}) async {
    // A monospace cell is about 0.6 of the font size wide.
    final fontSize = widthDots / columns / 0.6 * (line.large ? 2 : 1);
    final painter = TextPainter(
      text: TextSpan(
        text: line.text,
        style: TextStyle(
          color: const Color(0xFF000000),
          fontSize: fontSize,
          fontFamily: 'monospace',
          fontWeight: line.bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textAlign: switch (line.align) {
        PrintAlign.left => TextAlign.left,
        PrintAlign.center => TextAlign.center,
        PrintAlign.right => TextAlign.right,
      },
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: widthDots.toDouble(), maxWidth: widthDots.toDouble());

    final height = painter.height.ceil().clamp(1, 1000);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..drawRect(Rect.fromLTWH(0, 0, widthDots.toDouble(), height.toDouble()), Paint()..color = const Color(0xFFFFFFFF));
    painter.paint(canvas, Offset.zero);
    final picture = recorder.endRecording();
    final image = await picture.toImage(widthDots, height);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    picture.dispose();
    painter.dispose();
    return img.Image.fromBytes(
      width: widthDots,
      height: height,
      bytes: bytes!.buffer,
      numChannels: 4,
    );
  }
}
