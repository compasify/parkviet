import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import '../../l10n/app_localizations.dart';
import 'waiter_context.dart';
import 'waiter_messages.dart';

/// Pours from a guest's kept bottle: scan the code on its label (the frame
/// of the scan is the bottle's photo) or type it, set the level left and
/// the ml poured. Pouring costs nothing and never raises the level.
class BottlePourScreen extends StatefulWidget {
  const BottlePourScreen({super.key, required this.waiter, this.workspaceId, this.scanner = true});

  final WaiterContext waiter;

  /// The order the pour is served to, when poured from one.
  final String? workspaceId;

  /// Whether to show the camera; tests and devices without one type the code.
  final bool scanner;

  @override
  State<BottlePourScreen> createState() => _BottlePourScreenState();
}

class _BottlePourScreenState extends State<BottlePourScreen> {
  final _code = TextEditingController();
  final _ml = TextEditingController();
  MobileScannerController? _camera;
  BottleKeep? _bottle;
  Uint8List? _photo;
  double _level = 0;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    if (widget.scanner) {
      _camera = MobileScannerController(formats: const [BarcodeFormat.qrCode], returnImage: true);
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    _code.dispose();
    _ml.dispose();
    super.dispose();
  }

  Future<void> _find(String code, {Uint8List? photo}) async {
    final l10n = AppLocalizations.of(context);
    final wanted = code.trim().toUpperCase();
    if (wanted.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final rows = await widget.waiter.api.bottles(widget.waiter.branchId, wanted);
      final bottle = rows.where((row) => row.code == wanted).firstOrNull ?? (rows.length == 1 ? rows.single : null);
      if (!mounted) return;
      setState(() {
        _bottle = bottle;
        _photo = photo ?? _photo;
        _level = (bottle?.levelPercent ?? 0).toDouble();
        _message = bottle == null ? l10n.waiterBottleNotFound : null;
      });
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _message = waiterFailureMessage(l10n, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final raw = capture.barcodes.map((code) => code.rawValue).whereType<String>().firstOrNull;
    if (raw == null || _busy || (_bottle != null && _bottle!.code == raw.trim().toUpperCase())) return;
    _code.text = raw.trim();
    unawaited(_find(raw, photo: capture.image));
  }

  Future<void> _pour() async {
    final l10n = AppLocalizations.of(context);
    final bottle = _bottle;
    final mlText = _ml.text.trim();
    final ml = mlText.isEmpty ? null : int.tryParse(mlText);
    if (bottle == null || _busy || (mlText.isNotEmpty && (ml == null || ml <= 0))) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final poured = await widget.waiter.api.pour(
        bottle.id,
        levelPercent: _level.round(),
        ml: ml,
        workspaceId: widget.workspaceId,
        photo: _photo,
      );
      if (!mounted) return;
      _ml.clear();
      setState(() {
        _bottle = poured;
        _level = poured.levelPercent.toDouble();
        _photo = null;
        _message = l10n.waiterBottlePoured(poured.levelPercent);
      });
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _message = waiterFailureMessage(l10n, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottle = _bottle;
    final camera = _camera;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.waiterBottleTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (camera != null)
            SizedBox(
              height: 220,
              child: MobileScanner(
                controller: camera,
                onDetect: _onDetect,
                errorBuilder: (context, error) => Center(child: Text(l10n.scanCameraUnavailable)),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('bottle-code'),
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: l10n.waiterBottleCode,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                key: const Key('bottle-find'),
                icon: const Icon(Icons.search),
                onPressed: () => _find(_code.text),
              ),
            ),
            onSubmitted: _find,
          ),
          if (_message != null)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(_message!, key: const Key('bottle-message'))),
          if (bottle != null) ...[
            const SizedBox(height: 12),
            ListTile(
              key: Key('bottle-${bottle.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text('${bottle.code} · ${bottle.productName ?? ''}'),
              subtitle: Text([
                if (bottle.guestName != null) bottle.guestName!,
                if (bottle.phone != null) bottle.phone!,
                l10n.waiterBottleLevel(bottle.levelPercent),
              ].join(' · ')),
              trailing: _photo == null ? null : Image.memory(_photo!, width: 56, height: 56, fit: BoxFit.cover),
            ),
            if (bottle.status == BottleKeepStatusEnum.kept) ...[
              Text(l10n.waiterBottleNewLevel(_level.round())),
              Slider(
                key: const Key('bottle-level'),
                value: _level,
                max: bottle.levelPercent.toDouble(),
                divisions: bottle.levelPercent > 0 ? bottle.levelPercent : null,
                label: '${_level.round()}%',
                onChanged: _busy || bottle.levelPercent == 0 ? null : (value) => setState(() => _level = value),
              ),
              TextField(
                key: const Key('bottle-ml'),
                controller: _ml,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.waiterBottleMl, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('bottle-pour'),
                onPressed: _busy ? null : _pour,
                icon: const Icon(Icons.local_bar),
                label: Text(l10n.waiterBottlePour),
              ),
            ] else
              Text(l10n.waiterBottleClosed),
          ],
        ],
      ),
    );
  }
}
