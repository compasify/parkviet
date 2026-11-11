import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/modes/print_station/print_commands.dart';
import 'package:parkviet_staff/modes/print_station/printer_profile.dart';
import 'package:parkviet_staff/modes/print_station/tspl_renderer.dart';

const label = PrinterProfile(
  id: 'posprn_2',
  name: 'Tem',
  connection: PrinterProfile.lan,
  address: '10.0.0.6',
  paper: '58mm',
  commandLanguage: 'tspl',
);

void main() {
  test('writes a TSPL program sized to its content', () {
    final program = ascii.decode(const TsplRenderer().render(const [
      TextCommand('Trà sữa "lớn"', align: PrintAlign.center, large: true),
      FeedCommand(1),
      QrCommand('W12', PrintAlign.left),
      BarcodeCommand('W12', PrintAlign.right),
      CutCommand(),
    ], label));

    final lines = program.split('\r\n');
    expect(lines.take(4), ['SIZE 48 mm,57 mm', 'GAP 2 mm,0 mm', 'DIRECTION 1', 'CLS']);
    // 13 characters at twice 12 dots, centred on 384 dots.
    expect(lines[4], r'TEXT 36,16,"2",0,2,2,"Tra sua \["]lon\["]"');
    expect(lines[5], 'QRCODE 0,88,M,4,A,0,"W12"');
    expect(lines[6], startsWith('BARCODE '));
    expect(lines[6], endsWith(',328,"128",64,1,0,2,2,"W12"'));
    expect(lines.sublist(7), ['PRINT 1,1', '']);
  });

  test('centres a short line on the label', () {
    final program = ascii.decode(const TsplRenderer().render(const [TextCommand('AB', align: PrintAlign.center)], label));
    // 384 dots wide, two 12-dot characters.
    expect(program, contains('TEXT 180,16,"2",0,1,1,"AB"'));
  });

  test('skips an empty barcode', () {
    final program = ascii.decode(const TsplRenderer().render(const [BarcodeCommand('', PrintAlign.left)], label));
    expect(program, isNot(contains('BARCODE')));
  });
}
