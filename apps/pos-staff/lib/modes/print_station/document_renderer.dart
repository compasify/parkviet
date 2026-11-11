import 'escpos_renderer.dart';
import 'print_commands.dart';
import 'printer_profile.dart';
import 'tspl_renderer.dart';

/// A PrintDocument v1 as the bytes its printer's command language takes.
class DocumentRenderer {
  const DocumentRenderer({required this.escPos, this.tspl = const TsplRenderer()});

  final EscPosRenderer escPos;
  final TsplRenderer tspl;

  Future<List<int>> render(Map<String, Object?> document, PrinterProfile printer) async {
    final commands = documentCommands(document, printer);
    return printer.isTspl
        ? tspl.render(commands, printer, label: documentLabel(document))
        : escPos.render(commands, printer);
  }
}
