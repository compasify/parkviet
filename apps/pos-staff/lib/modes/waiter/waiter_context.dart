import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_api/pos_api.dart';

import '../../core/errors.dart';
import 'void_reasons.dart';
import 'waiter_api.dart';

/// What every waiter screen shares: the API, the branch, this phone as an
/// editor of orders, the branch events and the menu.
class WaiterContext {
  WaiterContext({
    required this.api,
    required this.branchId,
    required this.deviceId,
    required this.editorId,
    required this.baseUrl,
    this.events = const Stream.empty(),
  }) : menu = MenuCache(api: api, branchId: branchId, events: events);

  final WaiterApi api;
  final String branchId;
  final String deviceId;

  /// This phone as the holder of an order's editing lease, the same for
  /// the whole run of the app.
  final String editorId;

  /// For images the server names by path.
  final String baseUrl;
  final Stream<Map<String, Object?>> events;
  final MenuCache menu;

  /// Why a sent dish may be voided here: the defaults until the branch's
  /// own are read, and still the defaults when they cannot be.
  final voidReasons = ValueNotifier<List<String>>(voidReasonChoices(null));

  /// The branch's POS modules that are on: a bar shows its tabs and kept
  /// bottles only where they run. Empty until read.
  final modules = ValueNotifier<Set<String>>(const {});

  /// What the person signed in may do here: a room's clock is run only by
  /// someone with `pos.timed.operate`. Empty until read.
  final capabilities = ValueNotifier<Set<String>>(const {});

  /// The person signed in, for the attendants book. Null until read.
  final staffId = ValueNotifier<String?>(null);

  Future<void> loadModules() async {
    try {
      modules.value = await api.modules(branchId);
    } on AppFailure {
      // The bar shortcuts stay hidden; the tables work as before.
    }
    try {
      capabilities.value = await api.capabilities(branchId);
    } on AppFailure {
      // The clock commands stay hidden; the server checks anyway.
    }
    try {
      staffId.value = await api.staffId(branchId);
    } on AppFailure {
      // Serving a room stays hidden.
    }
  }

  Future<void> loadVoidReasons() async {
    try {
      voidReasons.value = voidReasonChoices(await api.voidReasons(branchId));
    } on AppFailure {
      // The server checks the reason anyway; the defaults stay.
    }
  }

  /// Events about one order.
  Stream<void> workspaceEvents(String workspaceId) => events.where((event) {
        final refs = event['refs'];
        return (event['event'] == 'workspace.updated' && event['id'] == workspaceId) ||
            (event['event'] == 'kitchen_ticket.updated' && refs is Map && refs['workspace_id'] == workspaceId);
      });

  /// The full address of a menu image.
  String? imageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$base${url.startsWith('/') ? '' : '/'}$url';
  }

  void dispose() {
    menu.dispose();
    voidReasons.dispose();
    modules.dispose();
    capabilities.dispose();
    staffId.dispose();
  }
}

/// The branch menu, read once and again whenever a dish is marked sold out
/// (`menu.sold_out`), so the phone dims it at once. The server still
/// refuses a sold-out dish.
class MenuCache {
  MenuCache({required this.api, required this.branchId, required Stream<Map<String, Object?>> events}) {
    _events = events.listen((event) {
      if (event['event'] == 'menu.sold_out') unawaited(load());
    });
  }

  final WaiterApi api;
  final String branchId;
  final menu = ValueNotifier<Menu?>(null);
  final failure = ValueNotifier<AppFailure?>(null);
  late final StreamSubscription<Map<String, Object?>> _events;

  Future<void> load() async {
    try {
      menu.value = await api.menu(branchId);
      failure.value = null;
    } on AppFailure catch (error) {
      failure.value = error;
    }
  }

  void dispose() {
    _events.cancel();
    menu.dispose();
    failure.dispose();
  }
}
