import 'printer_profile.dart';

// A PrintDocument v1 flattened to what a receipt printer does: lines of
// text, feeds, codes and a cut. The same flattening the web counter uses for
// its direct printers (packages/pos-shared print-commands), so a document
// looks the same on every printer. Images are skipped.

enum PrintAlign { left, center, right }

sealed class PrintCommand {
  const PrintCommand();
}

class TextCommand extends PrintCommand {
  const TextCommand(this.text, {this.align = PrintAlign.left, this.bold = false, this.large = false});

  final String text;
  final PrintAlign align;
  final bool bold;
  final bool large;

  @override
  bool operator ==(Object other) =>
      other is TextCommand && other.text == text && other.align == align && other.bold == bold && other.large == large;

  @override
  int get hashCode => Object.hash(text, align, bold, large);

  @override
  String toString() => 'TextCommand($text, $align, bold: $bold, large: $large)';
}

class FeedCommand extends PrintCommand {
  const FeedCommand(this.lines);

  final int lines;
}

class QrCommand extends PrintCommand {
  const QrCommand(this.value, this.align);

  final String value;
  final PrintAlign align;
}

class BarcodeCommand extends PrintCommand {
  const BarcodeCommand(this.value, this.align);

  final String value;
  final PrintAlign align;
}

class CutCommand extends PrintCommand {
  const CutCommand();
}

const _mmPerFeed = 4;

final _control = RegExp('[\u0000-\u001f\u007f]');

String _clean(String value) => value.replaceAll(_control, ' ');

int _length(String value) => value.runes.length;

String _take(List<int> runes, int start, int end) => String.fromCharCodes(runes.sublist(start, end));

List<String> wrapText(String input, int width) {
  final lines = <String>[];
  var line = '';
  for (final word in _clean(input).split(' ').where((part) => part.isNotEmpty)) {
    var rest = word.runes.toList();
    if (line.isNotEmpty && _length(line) + 1 + rest.length <= width) {
      line = '$line $word';
      continue;
    }
    if (line.isNotEmpty) lines.add(line);
    line = '';
    while (rest.length > width) {
      lines.add(_take(rest, 0, width));
      rest = rest.sublist(width);
    }
    line = String.fromCharCodes(rest);
  }
  if (line.isNotEmpty) lines.add(line);
  return lines;
}

List<String> _pairLines(String left, String right, int width) {
  final label = _clean(left).trim();
  final value = _clean(right).trim();
  final gap = width - _length(label) - _length(value);
  if (gap >= 1) return ['$label${' ' * gap}$value'];
  return [
    ...wrapText(label, width),
    for (final line in wrapText(value, width)) '${' ' * (width - _length(line))}$line',
  ];
}

PrintAlign _align(Object? value) => switch (value) {
      'center' => PrintAlign.center,
      'right' => PrintAlign.right,
      _ => PrintAlign.left,
    };

List<Map<String, Object?>> _maps(Object? value) =>
    value is List ? [for (final item in value) if (item is Map) item.cast<String, Object?>()] : const [];

List<String> _strings(Object? value) => value is List ? [for (final item in value) '$item'] : const [];

String? _string(Object? value) => value is String ? value : null;

/// The commands for one document on one printer. [document] is the JSON of
/// the document as the server sent it.
List<PrintCommand> documentCommands(Map<String, Object?> document, PrinterProfile printer) {
  final width = printer.columns;
  final commands = <PrintCommand>[];

  void text(String line, {PrintAlign align = PrintAlign.left, bool bold = false, bool large = false}) =>
      commands.add(TextCommand(line, align: align, bold: bold, large: large));

  void wrapped(String value, {PrintAlign align = PrintAlign.left, bool bold = false, bool large = false}) {
    for (final line in wrapText(value, large ? width ~/ 2 : width)) {
      text(line, align: align, bold: bold, large: large);
    }
  }

  void row(Map<String, Object?> item) {
    final strong = item['strong'] == true;
    for (final line in _pairLines('${item['label'] ?? ''}', '${item['value'] ?? ''}', width)) {
      text(line, bold: strong);
    }
  }

  void rule([String mark = '-']) => text(mark * width);

  void block(Map<String, Object?> item) {
    final align = _align(item['align']);
    switch (item['kind']) {
      case 'text':
        for (final line in _strings(item['lines'])) {
          wrapped(line, align: align, bold: item['bold'] == true, large: item['size'] == 'l');
        }
      case 'title':
        wrapped('${item['title'] ?? ''}', align: PrintAlign.center, bold: true, large: true);
        final number = _string(item['number']);
        if (number != null && number.isNotEmpty) wrapped(number, align: PrintAlign.center, bold: true);
      case 'qr':
        commands.add(QrCommand('${item['value'] ?? ''}', align));
        final caption = _string(item['caption']);
        if (caption != null && caption.isNotEmpty) wrapped(caption, align: align);
      case 'barcode':
        commands.add(BarcodeCommand('${item['value'] ?? ''}', align));
      case 'divider':
        rule(item['style'] == 'solid' ? '=' : '-');
      case 'spacer':
        final mm = item['mm'];
        final lines = mm is num ? (mm / _mmPerFeed).round() : 1;
        commands.add(FeedCommand(lines < 1 ? 1 : lines));
      case 'signatures':
        for (final party in _maps(item['parties'])) {
          wrapped('${party['label'] ?? ''}');
          commands.add(const FeedCommand(3));
        }
      default:
        // Images, and kinds a newer server may add.
        break;
    }
  }

  String named(Map<String, Object?> item) {
    final index = item['index'];
    final name = '${item['name'] ?? ''}';
    return index == null ? name : '$index. $name';
  }

  void lines(Map<String, Object?> section) {
    if (section['layout'] == 'stacked') {
      for (final item in _maps(section['items'])) {
        final amount = _string(item['amount']);
        if (amount == null) {
          wrapped(named(item));
        } else {
          for (final line in _pairLines(named(item), amount, width)) {
            text(line);
          }
        }
        for (final detail in _strings(item['details'])) {
          wrapped('  $detail');
        }
      }
      return;
    }
    final columns = _maps(section['columns']);
    if (columns.isNotEmpty) {
      wrapped(columns.map((column) => '${column['label'] ?? ''}').join(' | '), align: PrintAlign.right, bold: true);
    }
    for (final item in _maps(section['rows'])) {
      wrapped(named(item));
      final cells = _strings(item['cells']);
      if (cells.isNotEmpty) wrapped(cells.join(' | '), align: PrintAlign.right);
      for (final detail in _strings(item['details'])) {
        wrapped('  $detail');
      }
    }
  }

  for (final banner in _strings(document['banners'])) {
    wrapped(banner, align: PrintAlign.center, bold: true);
  }
  _maps(document['header']).forEach(block);
  _maps(document['meta']).forEach(row);
  rule();
  final section = document['lines'];
  if (section is Map) lines(section.cast<String, Object?>());
  rule();
  _maps(document['totals']).forEach(row);
  _maps(document['payments']).forEach(row);
  final payQr = document['payQr'];
  if (payQr is Map) {
    commands.add(QrCommand('${payQr['value'] ?? ''}', PrintAlign.center));
    wrapped('${payQr['caption'] ?? ''}', align: PrintAlign.center);
    for (final line in _strings(payQr['lines'])) {
      wrapped(line, align: PrintAlign.center);
    }
  }
  for (final note in _strings(document['notes'])) {
    wrapped(note);
  }
  _maps(document['footer']).forEach(block);
  final disclaimer = _string(document['disclaimer']);
  if (disclaimer != null && disclaimer.isNotEmpty) wrapped(disclaimer, align: PrintAlign.center);
  commands.add(const FeedCommand(3));
  if (printer.cut) commands.add(const CutCommand());
  return commands;
}
