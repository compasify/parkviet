import 'printer_profile.dart';

/// A PrintDocument v1 test page, printed from the station without the
/// server, to check that a printer is reachable and how it prints.
Map<String, Object?> stationTestPage({
  required String title,
  required String sample,
  required PrinterProfile printer,
  required String stationName,
  required String printedAt,
}) =>
    {
      'version': 1,
      'kind': 'test',
      'documentType': null,
      'page': {'margin_mm': 3, 'font': 'sans', 'font_size': 'm', 'line_spacing': 1.35},
      'banners': <String>[],
      'header': [
        {'kind': 'title', 'title': title, 'number': null},
        {
          'kind': 'text',
          'lines': [printer.name, stationName],
          'align': 'center',
          'bold': false,
          'size': 'm',
        },
      ],
      'meta': [
        {'label': printer.connection, 'value': printer.address ?? printer.bluetoothId ?? '-'},
        {'label': printer.paper, 'value': '${printer.columns}'},
        {'label': printer.commandLanguage, 'value': printedAt},
      ],
      'lines': {
        'layout': 'stacked',
        'items': [
          {'index': null, 'name': sample, 'amount': null, 'details': <String>[]},
        ],
      },
      'totals': <Object?>[],
      'payments': <Object?>[],
      'payQr': null,
      'notes': <String>[],
      'footer': [
        {'kind': 'qr', 'value': 'parkviet', 'caption': null, 'align': 'center'},
      ],
      'disclaimer': null,
    };
