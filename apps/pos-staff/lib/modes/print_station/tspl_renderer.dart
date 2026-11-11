import 'dart:convert';

import 'print_commands.dart';
import 'printer_profile.dart';
import 'vietnamese_text.dart';

/// Print commands as TSPL for label printers, sized to the content. Uses
/// the built-in 12×20 dot font, so text is ASCII without marks.
class TsplRenderer {
  const TsplRenderer();

  static const _dotsPerMm = 8; // 203 dpi
  static const _charWidth = 12;
  static const _lineHeight = 24;
  static const _margin = 16;
  static const _qrModule = 4;
  static const _barcodeHeight = 64;

  List<int> render(List<PrintCommand> commands, PrinterProfile printer) {
    final width = printer.dots;
    final body = <String>[];
    var y = _margin;

    for (final command in commands) {
      switch (command) {
        case TextCommand(:final text, :final align, :final large):
          final scale = large ? 2 : 1;
          final line = foldToAscii(text);
          final x = _x(align, line.length * _charWidth * scale, width);
          body.add('TEXT $x,$y,"2",0,$scale,$scale,"${_escape(line)}"');
          y += _lineHeight * scale;
        case FeedCommand(:final lines):
          y += _lineHeight * lines;
        case QrCommand(:final value, :final align):
          final data = foldToAscii(value);
          // Version 10 at most for a label: 57 modules.
          final side = 57 * _qrModule;
          body.add('QRCODE ${_x(align, side, width)},$y,M,$_qrModule,A,0,"${_escape(data)}"');
          y += side + _lineHeight ~/ 2;
        case BarcodeCommand(:final value, :final align):
          final data = foldToAscii(value);
          if (data.isEmpty) continue;
          final estimate = (data.length * 11 + 35) * 2;
          body.add('BARCODE ${_x(align, estimate, width)},$y,"128",$_barcodeHeight,1,0,2,2,"${_escape(data)}"');
          y += _barcodeHeight + _lineHeight * 2;
        case CutCommand():
          // A label printer stops at the gap; there is nothing to cut.
          break;
      }
    }

    final widthMm = (width / _dotsPerMm).ceil();
    final heightMm = ((y + _margin) / _dotsPerMm).ceil();
    final program = [
      'SIZE $widthMm mm,$heightMm mm',
      'GAP 2 mm,0 mm',
      'DIRECTION 1',
      'CLS',
      ...body,
      'PRINT 1,1',
      '',
    ].join('\r\n');
    return ascii.encode(program);
  }

  static int _x(PrintAlign align, int contentWidth, int width) {
    final free = width - contentWidth;
    if (free <= 0) return 0;
    return switch (align) {
      PrintAlign.left => 0,
      PrintAlign.center => free ~/ 2,
      PrintAlign.right => free,
    };
  }

  /// TSPL strings cannot hold a bare double quote.
  static String _escape(String value) => value.replaceAll('"', r'\["]');
}
