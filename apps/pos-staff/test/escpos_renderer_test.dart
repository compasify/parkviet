import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:parkviet_staff/modes/print_station/document_renderer.dart';
import 'package:parkviet_staff/modes/print_station/escpos_renderer.dart';
import 'package:parkviet_staff/modes/print_station/print_commands.dart';
import 'package:parkviet_staff/modes/print_station/printer_profile.dart';
import 'package:parkviet_staff/modes/print_station/text_rasterizer.dart';

/// The documents the server renders in its own print document specs, so the
/// station is checked against what the server really sends.
const fixtures = '../../server/spec/fixtures/print_documents';

Map<String, Object?> fixtureDocument(String name) {
  final json = jsonDecode(File('$fixtures/$name.json').readAsStringSync()) as Map<String, Object?>;
  return (json['document']! as Map).cast<String, Object?>();
}

List<String> fixtureNames() => [
      for (final file in Directory(fixtures).listSync().whereType<File>())
        if (file.path.endsWith('.json') && !file.path.endsWith('schema.json'))
          file.uri.pathSegments.last.replaceAll('.json', ''),
    ]..sort();

/// Compares with the file of that name in test/goldens; `flutter test --update-goldens`
/// rewrites the file after a deliberate change.
void expectBytesGolden(List<int> bytes, String name) {
  final file = File('test/goldens/$name');
  if (autoUpdateGoldenFiles) {
    file
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    return;
  }
  expect(file.existsSync(), isTrue, reason: 'missing golden $name; run flutter test --update-goldens');
  final golden = file.readAsBytesSync();
  expect(bytes.length, golden.length, reason: '$name length');
  for (var i = 0; i < golden.length; i++) {
    if (bytes[i] != golden[i]) fail('$name differs at byte $i: ${bytes[i]} != ${golden[i]}');
  }
}

/// Records the lines it is asked to draw and returns a blank strip.
class RecordingRasterizer implements TextRasterizer {
  final lines = <TextCommand>[];

  @override
  Future<img.Image> rasterize(TextCommand line, {required int widthDots, required int columns}) async {
    lines.add(line);
    return img.Image(width: widthDots, height: 24)..clear(img.ColorRgb8(255, 255, 255));
  }
}

PrinterProfile escpos({String paper = '80mm', Map<String, Object?> settings = const {}}) => PrinterProfile(
      id: 'posprn_1',
      name: 'Quầy',
      connection: PrinterProfile.lan,
      address: '10.0.0.5',
      paper: paper,
      settings: settings,
    );

bool containsSequence(List<int> bytes, List<int> sequence) {
  for (var i = 0; i + sequence.length <= bytes.length; i++) {
    var match = true;
    for (var j = 0; j < sequence.length; j++) {
      if (bytes[i + j] != sequence[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

const escInit = [0x1b, 0x40];
const gsCut = [0x1d, 0x56];
const gsQrStore = [0x1d, 0x28, 0x6b];
const gsRaster = [0x1d, 0x76, 0x30];
const gsReverseOn = [0x1d, 0x42, 0x01];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DocumentRenderer renderer;
  setUpAll(() async => renderer = DocumentRenderer(escPos: await EscPosRenderer.load()));

  group('server documents', () {
    for (final name in fixtureNames()) {
      for (final paper in ['80mm', '58mm']) {
        test('$name on $paper matches its golden bytes', () async {
          final bytes = await renderer.render(fixtureDocument(name), escpos(paper: paper));
          expectBytesGolden(bytes, '$name-$paper.escpos');
        });
      }
    }
  });

  test('a sale starts with a reset, prints its title without marks and ends with a cut', () async {
    final bytes = await renderer.render(fixtureDocument('sale-default'), escpos());
    expect(bytes.take(2), escInit);
    expect(containsSequence(bytes, ascii.encode('PHIEU BAN HANG')), isTrue);
    expect(containsSequence(bytes, utf8.encode('PHIẾU')), isFalse);
    expect(containsSequence(bytes, gsQrStore), isTrue, reason: 'the pay QR');
    expect(containsSequence(bytes.sublist(bytes.length - 8), gsCut), isTrue);
  });

  test('sends no byte above ASCII in text mode outside codes', () async {
    final commands = documentCommands(fixtureDocument('sale-default'), escpos())
        .where((command) => command is TextCommand || command is FeedCommand)
        .toList();
    final bytes = await EscPosRenderer(profile: renderer.escPos.profile).render(commands, escpos());
    expect(bytes.where((byte) => byte > 0x7f), isEmpty);
  });

  test('prints an inverted line in reverse and only that line', () async {
    final escPos = EscPosRenderer(profile: renderer.escPos.profile);
    final inverted = await escPos.render(const [TextCommand('Ghi chu', invert: true)], escpos());
    final plain = await escPos.render(const [TextCommand('Ghi chu')], escpos());
    expect(containsSequence(inverted, gsReverseOn), isTrue);
    expect(containsSequence(plain, gsReverseOn), isFalse);
  });

  test('leaves the cut out for a printer without a cutter', () async {
    final bytes = await renderer.render(fixtureDocument('sale-default'), escpos(settings: {'cut': false}));
    expect(containsSequence(bytes, gsCut), isFalse);
  });

  test('the bitmap code page draws every line with its marks', () async {
    final rasterizer = RecordingRasterizer();
    final bitmap = DocumentRenderer(escPos: EscPosRenderer(profile: renderer.escPos.profile, rasterizer: rasterizer));
    final bytes = await bitmap.render(fixtureDocument('sale-default'), escpos(settings: {'codepage': 'bitmap'}));

    expect(rasterizer.lines.map((line) => line.text), contains('PHIẾU BÁN HÀNG'));
    expect(containsSequence(bytes, gsRaster), isTrue);
    expect(containsSequence(bytes, ascii.encode('PHIEU BAN HANG')), isFalse);
  });

  test('doubles a brace in Code 128 data', () async {
    final bytes = await renderer.escPos.render([const BarcodeCommand('R{1', PrintAlign.center)], escpos());
    expect(containsSequence(bytes, ascii.encode('{BR{{1')), isTrue);
  });
}
