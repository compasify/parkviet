import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_api/pos_api.dart';

import '../../../core/errors.dart';
import 'guest_orders_api.dart';

/// What guests at the branch wait for, kept fresh by the branch events
/// (`guest_order.*`, `guest_request.*`): orders to accept or reject and
/// calls for staff or the bill. [onArrive] rings the phone when a guest
/// orders or calls in the area this phone looks at.
class GuestInbox {
  GuestInbox({
    required this.api,
    required this.branchId,
    required Stream<Map<String, Object?>> events,
    this.onArrive,
    String? areaId,
  }) : _areaId = areaId {
    _events = events.listen((event) {
      final name = event['event'];
      if (name is! String || !_names.contains(name)) return;
      unawaited(refresh(announce: name.endsWith('.created')));
    });
  }

  static const _names = {
    'guest_order.created',
    'guest_order.updated',
    'guest_request.created',
    'guest_request.updated',
  };

  final GuestOrdersApi api;
  final String branchId;
  final VoidCallback? onArrive;
  String? _areaId;
  late final StreamSubscription<Map<String, Object?>> _events;

  final orders = ValueNotifier<List<GuestOrder>>(const []);
  final requests = ValueNotifier<List<GuestRequest>>(const []);
  final failure = ValueNotifier<AppFailure?>(null);

  /// The area shown, or every area when null.
  String? get areaId => _areaId;

  /// Orders and open requests waiting for staff.
  int get waiting => orders.value.length + requests.value.length;

  Future<void> show(String? areaId) {
    _areaId = areaId;
    return refresh();
  }

  Future<void> refresh({bool announce = false}) async {
    try {
      final before = waiting;
      final nextOrders = await api.pending(branchId, areaId: _areaId);
      final nextRequests = await api.requests(branchId, areaId: _areaId);
      orders.value = nextOrders;
      requests.value = nextRequests
          .where((row) => row.status == GuestRequestStatusEnum.open)
          .toList();
      failure.value = null;
      if (announce && waiting > before) onArrive?.call();
    } on AppFailure catch (error) {
      failure.value = error;
    }
  }

  void dispose() {
    _events.cancel();
    orders.dispose();
    requests.dispose();
    failure.dispose();
  }
}
