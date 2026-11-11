import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import 'print_commands.dart';
import 'printer_profile.dart';
import 'text_rasterizer.dart';
import 'vietnamese_text.dart';

/// Print commands as ESC/POS bytes. Text goes out as ASCII without marks,
/// or, when the printer's code page is `bitmap`, as one raster image per
/// line so every Vietnamese letter prints.
class EscPosRenderer {
  EscPosRenderer({required this.profile, this.rasterizer = const FlutterTextRasterizer()});

  /// Loads the printer capability table bundled with esc_pos_utils_plus.
  static Future<EscPosRenderer> load({TextRasterizer rasterizer = const FlutterTextRasterizer()}) async =>
      EscPosRenderer(profile: await CapabilityProfile.load(), rasterizer: rasterizer);

  final CapabilityProfile profile;
  final TextRasterizer rasterizer;

  Future<List<int>> render(List<PrintCommand> commands, PrinterProfile printer) async {
    final generator = Generator(printer.is58mm ? PaperSize.mm58 : PaperSize.mm80, profile);
    final bytes = <int>[...generator.reset()];
    for (final command in commands) {
      switch (command) {
        case TextCommand():
          bytes.addAll(await _text(generator, command, printer));
        case FeedCommand(:final lines):
          bytes.addAll(generator.feed(lines));
        case QrCommand(:final value, :final align):
          bytes.addAll(_qr(generator, value, align, printer));
        case BarcodeCommand(:final value, :final align):
          final data = foldToAscii(value);
          if (data.isNotEmpty) {
            bytes.addAll(generator.barcode(
              Barcode.code128('{B${data.replaceAll('{', '{{')}'.split('')),
              align: _posAlign(align),
            ));
          }
        case CutCommand():
          bytes.addAll(generator.cut());
      }
    }
    return bytes;
  }

  Future<List<int>> _text(Generator generator, TextCommand line, PrinterProfile printer) async {
    if (printer.bitmapText) {
      final image = await rasterizer.rasterize(line, widthDots: printer.dots, columns: printer.columns);
      return generator.imageRaster(image, align: PosAlign.left);
    }
    final size = line.large ? PosTextSize.size2 : PosTextSize.size1;
    return generator.text(
      foldToAscii(line.text),
      styles: PosStyles(align: _posAlign(line.align), bold: line.bold, height: size, width: size),
      maxCharsPerLine: printer.columns,
    );
  }

  List<int> _qr(Generator generator, String value, PrintAlign align, PrinterProfile printer) {
    try {
      return generator.qrcode(value, align: _posAlign(align), size: printer.is58mm ? QRSize.size5 : QRSize.size6);
    } on ArgumentError {
      // ESC/POS carries a QR as Latin-1; print what it says instead.
      return generator.text(foldToAscii(value), styles: PosStyles(align: _posAlign(align)));
    }
  }

  static PosAlign _posAlign(PrintAlign align) => switch (align) {
        PrintAlign.left => PosAlign.left,
        PrintAlign.center => PosAlign.center,
        PrintAlign.right => PosAlign.right,
      };
}
