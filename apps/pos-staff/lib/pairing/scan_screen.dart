import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/session.dart';
import '../l10n/app_localizations.dart';
import 'pairing_errors.dart';
import 'pairing_payload.dart';

/// Scans the pairing QR and pairs at once.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  bool _working = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_working) return;
    final raw = capture.barcodes.map((code) => code.rawValue).whereType<String>().firstOrNull;
    if (raw == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final payload = PairingPayload.parse(raw);
      await ref.read(sessionProvider.notifier).pair(serverUrl: payload.url, code: payload.code);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = pairingErrorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanTitle)),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.scanCameraUnavailable, textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _working
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 12),
                      Text(l10n.pairingWorking),
                    ],
                  )
                : Text(
                    _error ?? l10n.scanHint,
                    textAlign: TextAlign.center,
                    style: _error == null ? null : TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
          ),
        ],
      ),
    );
  }
}
