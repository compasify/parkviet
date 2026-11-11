import 'dart:convert';
import 'dart:io';

import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import '../printer_profile.dart';
import 'printer_driver.dart';

/// The printer built into a Sunmi terminal, through its print service.
/// Android only.
class SunmiDriver implements PrinterDriver {
  const SunmiDriver();

  @override
  Future<void> send(PrinterProfile printer, List<int> bytes) async {
    if (!Platform.isAndroid) throw const PrinterDeliveryError('sunmi: only on Sunmi Android devices');
    try {
      if (printer.isTspl) {
        await SunmiPrinter.printTSPL(data: ascii.decode(bytes));
      } else {
        await SunmiPrinter.printEscPos(bytes);
      }
    } on Exception catch (error) {
      throw PrinterDeliveryError('sunmi: $error');
    }
  }
}
