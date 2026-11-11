import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Asks how many guests sit down, on large number keys. Null when closed.
Future<int?> askGuestCount(BuildContext context, {required String table, int? capacity}) => showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => GuestKeypad(table: table, capacity: capacity),
    );

class GuestKeypad extends StatefulWidget {
  const GuestKeypad({super.key, required this.table, this.capacity});

  final String table;
  final int? capacity;

  @override
  State<GuestKeypad> createState() => _GuestKeypadState();
}

class _GuestKeypadState extends State<GuestKeypad> {
  String _digits = '';

  int? get _count => int.tryParse(_digits);

  void _press(String key) => setState(() {
        if (key == '<') {
          if (_digits.isNotEmpty) _digits = _digits.substring(0, _digits.length - 1);
        } else if (_digits.length < 3) {
          _digits = _digits == '0' ? key : '$_digits$key';
        }
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final count = _count;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.waiterGuestsFor(widget.table), style: theme.textTheme.titleLarge),
          if (widget.capacity != null) Text(l10n.waiterCapacity(widget.capacity!)),
          const SizedBox(height: 8),
          Text(
            _digits.isEmpty ? '–' : _digits,
            key: const Key('guest-count'),
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final key in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '<', '0'])
                FilledButton.tonal(
                  key: Key('guest-key-$key'),
                  onPressed: () => _press(key),
                  child: key == '<'
                      ? const Icon(Icons.backspace_outlined)
                      : Text(key, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                ),
              FilledButton(
                key: const Key('guest-confirm'),
                onPressed: count != null && count > 0 ? () => Navigator.of(context).pop(count) : null,
                child: Text(l10n.waiterOpenTable, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
