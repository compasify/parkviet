import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/modes/print_station/print_commands.dart';
import 'package:parkviet_staff/modes/print_station/printer_profile.dart';
import 'package:parkviet_staff/modes/print_station/vietnamese_text.dart';

// The same document and expectations as the web counter's print-commands
// tests, so both flatten a document the same way.
const hostile = '</text><cut type="feed"/>&\'\\';

const document = <String, Object?>{
  'banners': ['BẢN SAO'],
  'header': [
    {'kind': 'title', 'title': 'PHIẾU', 'number': 'R1'},
    {
      'kind': 'text',
      'lines': [hostile],
      'align': 'center',
      'bold': true,
      'size': 'l',
    },
    {'kind': 'image', 'src': '/l.png', 'alt': '', 'widthPct': 50, 'align': 'left', 'monochrome': false},
    {'kind': 'divider', 'style': 'solid'},
    {'kind': 'spacer', 'mm': 8},
  ],
  'meta': [
    {'label': 'Khách', 'value': hostile},
  ],
  'lines': {
    'layout': 'stacked',
    'items': [
      {
        'index': 1,
        'name': hostile,
        'amount': '1 ₫',
        'details': ['d'],
      },
    ],
  },
  'totals': [
    {'label': 'Tổng', 'value': '1 ₫', 'strong': true},
  ],
  'payments': <Object?>[],
  'payQr': {
    'value': 'QR&<',
    'caption': 'Quét',
    'lines': ['a'],
  },
  'notes': [hostile],
  'footer': [
    {'kind': 'qr', 'value': 'https://a.test/?a=1&b=2', 'caption': null, 'align': 'right'},
    {'kind': 'barcode', 'value': 'R{1', 'align': 'center'},
    {
      'kind': 'signatures',
      'parties': [
        {'party': 'buyer', 'label': 'Khách'},
      ],
    },
  ],
  'disclaimer': 'x',
};

PrinterProfile printer({String paper = '80mm', Map<String, Object?> settings = const {}}) => PrinterProfile(
      id: 'posprn_1',
      name: 'Bếp',
      connection: PrinterProfile.lan,
      address: '10.0.0.5',
      paper: paper,
      settings: settings,
    );

void main() {
  final commands = documentCommands(document, printer());

  test('uses the paper width unless the printer sets one', () {
    expect(printer(paper: '58mm').columns, 32);
    expect(printer().columns, 48);
    expect(printer(settings: {'char_width': 42}).columns, 42);
  });

  test('wraps by words and breaks words longer than the line', () {
    expect(wrapText('một hai ba', 7), ['một hai', 'ba']);
    expect(wrapText('abcdefgh', 3), ['abc', 'def', 'gh']);
  });

  test('keeps every line within the paper', () {
    for (final command in commands.whereType<TextCommand>()) {
      expect(command.text.runes.length, lessThanOrEqualTo(command.large ? 24 : 48), reason: command.text);
    }
  });

  test('removes control characters a document could carry', () {
    expect(wrapText('a\u001b@b\nc', 48).single, 'a @b c');
  });

  test('skips images and ends with a cut', () {
    expect(commands.last, isA<CutCommand>());
    expect(commands.whereType<CutCommand>(), hasLength(1));
  });

  test('leaves the cut out when the printer has no cutter', () {
    final uncut = documentCommands(document, printer(settings: {'cut': false}));
    expect(uncut.whereType<CutCommand>(), isEmpty);
  });

  test('prints the right two columns of a row', () {
    final first = documentCommands(
      {
        ...document,
        'banners': <Object?>[],
        'header': <Object?>[],
        'meta': [
          {'label': 'A', 'value': 'B'},
        ],
      },
      printer(paper: '58mm'),
    ).first;
    expect(first, TextCommand('A${' ' * 30}B'));
  });

  test('keeps the codes, the title and the pay QR in order', () {
    expect(commands.first, const TextCommand('BẢN SAO', align: PrintAlign.center, bold: true));
    expect(commands[1], const TextCommand('PHIẾU', align: PrintAlign.center, bold: true, large: true));
    final codes = commands.where((command) => command is QrCommand || command is BarcodeCommand).toList();
    expect(codes.map((code) => code is QrCommand ? code.value : (code as BarcodeCommand).value),
        ['QR&<', 'https://a.test/?a=1&b=2', 'R{1']);
  });

  test('ignores a block kind it does not know', () {
    final plain = documentCommands({
      'header': [
        {'kind': 'hologram'},
      ],
    }, printer());
    expect(plain.whereType<TextCommand>().map((line) => line.text), ['-' * 48, '-' * 48]);
  });

  test('folds Vietnamese to ASCII for printers without the code page', () {
    expect(foldToAscii('PHIẾU BÁN HÀNG – Đơn 1 ₫ × 2'), 'PHIEU BAN HANG - Don 1 d x 2');
    expect(foldToAscii('ửỡợ ỨỪ'), 'uoo UU');
    expect(foldToAscii('日本'), '??');
  });
}
