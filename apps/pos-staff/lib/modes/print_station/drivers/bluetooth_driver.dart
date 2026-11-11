import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../printer_profile.dart';
import 'printer_driver.dart';

/// ESC/POS over Bluetooth. Most cheap printers speak Bluetooth Classic
/// (SPP), which only Android can open, through a small platform channel.
/// Printers that speak BLE work on both platforms. On iOS, Classic needs an
/// MFi printer, so iOS supports BLE only.
class BluetoothDriver implements PrinterDriver {
  const BluetoothDriver({MethodChannel channel = sppChannel}) : _channel = channel;

  static const sppChannel = MethodChannel('vn.parkviet.staff/bluetooth_spp');

  final MethodChannel _channel;

  @override
  Future<void> send(PrinterProfile printer, List<int> bytes) async {
    final id = (printer.bluetoothId ?? '').trim();
    if (id.isEmpty) throw const PrinterDeliveryError('bluetooth: no printer id');

    if (Platform.isAndroid && await _sendClassic(id, bytes)) return;
    await _sendBle(id, bytes);
  }

  /// False when the printer is a BLE-only device.
  Future<bool> _sendClassic(String address, List<int> bytes) async {
    // Asking for bonded devices makes the plugin request the Bluetooth
    // permission the classic socket also needs.
    await FlutterBluePlus.bondedDevices;
    try {
      await _channel.invokeMethod<void>('write', {'address': address, 'bytes': Uint8List.fromList(bytes)});
      return true;
    } on PlatformException catch (error) {
      if (error.code == 'not_classic') return false;
      throw PrinterDeliveryError('bluetooth: ${error.code} ${error.message ?? ''}'.trim());
    }
  }

  Future<void> _sendBle(String id, List<int> bytes) async {
    final device = BluetoothDevice.fromId(id);
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      final services = await device.discoverServices();
      final target = _writable(services);
      if (target == null) throw const PrinterDeliveryError('bluetooth: no writable characteristic');
      final withoutResponse = !target.properties.write;
      final chunk = (device.mtuNow - 3).clamp(20, 512);
      for (var start = 0; start < bytes.length; start += chunk) {
        final end = start + chunk < bytes.length ? start + chunk : bytes.length;
        await target.write(bytes.sublist(start, end), withoutResponse: withoutResponse);
      }
    } on FlutterBluePlusException catch (error) {
      throw PrinterDeliveryError('bluetooth: ${error.description ?? error.code}');
    } on TimeoutException {
      throw const PrinterDeliveryError('bluetooth: timeout');
    } finally {
      await device.disconnect();
    }
  }

  static BluetoothCharacteristic? _writable(List<BluetoothService> services) {
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        final properties = characteristic.properties;
        if (properties.write || properties.writeWithoutResponse) return characteristic;
      }
    }
    return null;
  }
}
