import '../printer_profile.dart';

/// Delivers rendered bytes to one kind of printer connection. The print
/// loop does not know which; a driver can be replaced by a platform channel
/// without touching it.
abstract interface class PrinterDriver {
  Future<void> send(PrinterProfile printer, List<int> bytes);
}

/// A delivery that did not reach the printer. [message] goes into the
/// job's report, so it is short and has no secrets.
class PrinterDeliveryError implements Exception {
  const PrinterDeliveryError(this.message);

  final String message;

  @override
  String toString() => message;
}
