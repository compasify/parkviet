import '../printer_profile.dart';
import 'bluetooth_driver.dart';
import 'lan_driver.dart';
import 'printer_driver.dart';
import 'sunmi_driver.dart';

typedef DriverResolver = PrinterDriver Function(PrinterProfile printer);

PrinterDriver defaultDriverFor(PrinterProfile printer) => switch (printer.connection) {
      PrinterProfile.lan => const LanDriver(),
      PrinterProfile.bluetooth => const BluetoothDriver(),
      PrinterProfile.sunmi => const SunmiDriver(),
      _ => throw PrinterDeliveryError('connection ${printer.connection} is not printed by a station'),
    };
