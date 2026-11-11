import 'dart:async';

import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/modes/kds/kds_repository.dart';
import 'package:pos_api/pos_api.dart';

/// Kitchen JSON shaped as the server answers it (KitchenTicket#to_pos,
/// Kitchen::Board).
Map<String, Object?> stationJson({String id = 'poskstation_1', String name = 'Bếp', int warn = 8, int late = 15}) => {
      'id': id,
      'branch_id': 'posbranch_1',
      'name': name,
      'kind': 'prep',
      'printer_id': null,
      'printer_name': null,
      'kds_enabled': true,
      'is_default': true,
      'warn_after_minutes': warn,
      'late_after_minutes': late,
      'position': 0,
      'active': true,
    };

Map<String, Object?> itemJson(
  String id, {
  String name = 'Phở bò',
  String quantity = '1.0',
  String status = 'new',
  String? note,
  List<Map<String, Object?>> modifiers = const [],
  String? readyAt,
  int recallCount = 0,
  int? seat,
  int? course,
}) =>
    {
      'id': id,
      'sale_line_id': 'possline_$id',
      'name': name,
      'modifiers': modifiers,
      'components': <Object?>[],
      'note': note,
      'quantity': quantity,
      'status': status,
      'started_at': null,
      'ready_at': readyAt,
      'served_at': null,
      'voided_at': null,
      'recalled_at': null,
      'recall_count': recallCount,
      'prep_seconds': null,
      'late': false,
      'seat': seat,
      'course': course,
    };

Map<String, Object?> ticketJson(
  String id, {
  required String sentAt,
  List<Map<String, Object?>>? items,
  int sequence = 1,
  String workspaceId = 'posws_aaaa1111',
  Map<String, Object?> header = const {'service_mode': 'counter'},
  bool done = false,
  String stationId = 'poskstation_1',
}) =>
    {
      'id': id,
      'workspace_id': workspaceId,
      'branch_id': 'posbranch_1',
      'kitchen_station_id': stationId,
      'station_name': 'Bếp',
      'station_kind': 'prep',
      'sequence': sequence,
      'kind': 'fire',
      'service_mode': header['service_mode'] ?? 'counter',
      'business_date': '2026-11-11',
      'header': header,
      'sent_at': sentAt,
      'done': done,
      'done_at': done ? sentAt : null,
      'items': items ?? [itemJson('poskitem_$id')],
    };

KitchenTicket ticket(Map<String, Object?> json) => standardSerializers.deserializeWith(KitchenTicket.serializer, json)!;

KitchenBoard board({
  required String serverNow,
  List<Map<String, Object?>> open = const [],
  List<Map<String, Object?>> done = const [],
  Map<String, Object?>? station,
  List<Map<String, Object?>> allDay = const [],
  List<Map<String, Object?>> expo = const [],
  List<Map<String, Object?>> held = const [],
}) =>
    standardSerializers.deserializeWith(KitchenBoard.serializer, {
      'branch_id': 'posbranch_1',
      'station': station,
      'stations': [station ?? stationJson()],
      'service_mode': null,
      'server_now': serverNow,
      'open': open,
      'done': done,
      'all_day': allDay,
      'expo': expo,
      'held': held,
    })!;

/// One all-day row as `Kitchen::Board` answers it.
Map<String, Object?> allDayJson(String key, {String name = 'Phở bò', String quantity = '3.0', List<String> itemIds = const []}) =>
    {
      'key': key,
      'name': name,
      'modifiers': <Object?>[],
      'quantity': quantity,
      'oldest_sent_at': '2026-11-11T11:54:00.000+07:00',
      'item_ids': itemIds,
    };

/// A [KitchenApi] that answers from memory and records what it was asked.
class FakeKitchenApi implements KitchenApi {
  FakeKitchenApi(this.current);

  KitchenBoard current;
  final calls = <String>[];

  /// Thrown by the next board fetches, in order.
  final boardFailures = <AppFailure>[];
  final actionResults = <KitchenTicket>[];
  Completer<void>? holdBoard;

  @override
  Future<KitchenBoard> board(List<String>? stationIds, {String? serviceMode}) async {
    calls.add('board:${stationIds?.join(',') ?? '*'}${serviceMode == null ? '' : ':$serviceMode'}');
    if (holdBoard != null) await holdBoard!.future;
    if (boardFailures.isNotEmpty) throw boardFailures.removeAt(0);
    return current;
  }

  @override
  Future<KitchenTicket> item(String itemId, KitchenAction action) async {
    calls.add('${action.name}:$itemId');
    return actionResults.removeAt(0);
  }

  @override
  Future<KitchenTicket> bump(String ticketId) async {
    calls.add('bump:$ticketId');
    return actionResults.removeAt(0);
  }

  /// Answered by the next [allDayBump].
  List<KitchenTicket> allDayResult = const [];

  @override
  Future<List<KitchenTicket>> allDayBump(List<String>? stationIds, String key, int quantity) async {
    calls.add('allDay:$key:$quantity');
    return allDayResult;
  }

  /// Answered by the next [serveOrder].
  List<KitchenTicket> servedResult = const [];

  @override
  Future<List<KitchenTicket>> serveOrder(String workspaceId) async {
    calls.add('serveOrder:$workspaceId');
    return servedResult;
  }

  @override
  Future<void> fireCourse(String workspaceId, int course) async {
    calls.add('fire:$workspaceId:$course');
  }

  @override
  Future<List<KitchenStation>> stations() async => current.stations.toList();

  @override
  Future<Device> selectStation(String? stationId) async {
    calls.add('select:${stationId ?? '*'}');
    return standardSerializers.deserializeWith(Device.serializer, {
      'id': 'posdev_1',
      'name': 'Bếp',
      'mode': 'kds',
      'status': 'active',
      'branch_id': 'posbranch_1',
      'kitchen_station_id': stationId,
    })!;
  }

  @override
  Future<List<KitchenMenuItem>> menuItems(String? stationId) async => const [];

  @override
  Future<void> soldOut({
    required String branchId,
    required String menuItemId,
    required bool soldOut,
    required String membershipId,
    required String pin,
  }) async =>
      calls.add('soldOut:$menuItemId:$soldOut');
}
