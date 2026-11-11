import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config.dart';

/// Wraps a mode's title. Holding it for [AppConfig.managerHoldDuration]
/// opens the manager PIN, then device information and unpairing.
class ManagerHoldArea extends StatefulWidget {
  const ManagerHoldArea({super.key, required this.child});

  final Widget child;

  @override
  State<ManagerHoldArea> createState() => _ManagerHoldAreaState();
}

class _ManagerHoldAreaState extends State<ManagerHoldArea> {
  Timer? _hold;

  void _start() {
    _hold?.cancel();
    _hold = Timer(AppConfig.managerHoldDuration, () {
      if (mounted) context.push('/manage/staff');
    });
  }

  void _cancel() => _hold?.cancel();

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: const Key('manager-hold-area'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _start(),
        onTapUp: (_) => _cancel(),
        onTapCancel: _cancel,
        child: widget.child,
      );
}
