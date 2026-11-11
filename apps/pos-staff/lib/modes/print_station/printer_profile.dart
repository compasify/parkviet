import 'package:pos_api/pos_api.dart';

/// What the station needs to reach and drive one printer, read from a
/// claimed job.
class PrinterProfile {
  const PrinterProfile({
    required this.id,
    required this.name,
    required this.connection,
    this.address,
    this.bluetoothId,
    this.paper = '80mm',
    this.commandLanguage = 'escpos',
    this.settings = const {},
  });

  factory PrinterProfile.fromClaim(PrintJobClaimPrinter printer) {
    final settings = printer.settings.value;
    return PrinterProfile(
      id: printer.id,
      name: printer.name,
      connection: printer.connection,
      address: printer.address,
      bluetoothId: printer.bluetoothId,
      paper: printer.paper,
      commandLanguage: printer.commandLanguage,
      settings: settings is Map ? settings.cast<String, Object?>() : const {},
    );
  }

  static const lan = 'escpos_lan';
  static const bluetooth = 'escpos_bluetooth';
  static const sunmi = 'sunmi_builtin';

  /// The `codepage` value that prints text as images, for printers without
  /// a Vietnamese code page.
  static const bitmapCodepage = 'bitmap';

  final String id;
  final String name;
  final String connection;
  final String? address;
  final String? bluetoothId;
  final String paper;
  final String commandLanguage;
  final Map<String, Object?> settings;

  bool get isTspl => commandLanguage == 'tspl';

  bool get is58mm => paper == '58mm';

  /// Characters per line: the printer's own setting, or the paper's.
  int get columns {
    final configured = settings['char_width'];
    return configured is int ? configured : (is58mm ? 32 : 48);
  }

  /// Printable width in dots at 203 dpi.
  int get dots => is58mm ? 384 : 576;

  bool get cut => settings['cut'] != false;

  bool get drawer => settings['drawer'] == true;

  bool get bitmapText => settings['codepage'] == bitmapCodepage;
}
