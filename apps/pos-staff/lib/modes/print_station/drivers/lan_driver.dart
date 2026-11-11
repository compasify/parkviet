import 'dart:async';
import 'dart:io';

import '../../../core/config.dart';
import '../printer_profile.dart';
import 'printer_driver.dart';

/// Raw TCP to the printer, port 9100 unless the address names another.
class LanDriver implements PrinterDriver {
  const LanDriver({this.timeout = AppConfig.printerSendTimeout, this.connect = Socket.connect});

  final Duration timeout;

  /// Opens the connection; a seam for tests.
  final Future<Socket> Function(dynamic host, int port, {Duration? timeout}) connect;

  @override
  Future<void> send(PrinterProfile printer, List<int> bytes) async {
    final (host, port) = parseAddress(printer.address);
    Socket? socket;
    try {
      socket = await connect(host, port, timeout: timeout);
      socket.add(bytes);
      await socket.flush().timeout(timeout);
      try {
        await socket.close().timeout(timeout);
      } on TimeoutException {
        // Every byte left with the flush; a printer slow to close its end
        // has still printed. Reporting a failure would print it twice.
      }
    } on SocketException catch (error) {
      throw PrinterDeliveryError('lan: ${error.osError?.message ?? error.message} ($host:$port)');
    } on TimeoutException {
      throw PrinterDeliveryError('lan: timeout ($host:$port)');
    } finally {
      socket?.destroy();
    }
  }

  /// `host` or `host:port`, as the printer's address is stored.
  static (String, int) parseAddress(String? address) {
    final value = (address ?? '').trim();
    if (value.isEmpty) throw const PrinterDeliveryError('lan: no address');
    final colon = value.lastIndexOf(':');
    if (colon < 0) return (value, AppConfig.lanPrinterPort);
    final port = int.tryParse(value.substring(colon + 1));
    if (port == null || port < 1 || port > 65535) throw PrinterDeliveryError('lan: bad address $value');
    return (value.substring(0, colon), port);
  }
}
