import 'dart:async';

import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/l10n/app_localizations.dart';
import 'package:parkviet_staff/modes/waiter/waiter_api.dart';
import 'package:pos_api/pos_api.dart';

/// Waiter JSON shaped as the server answers it (Menu, Workspace#to_pos,
/// ResourceBoard, ReadyFeed).
T parse<T>(Serializer<T> serializer, Map<String, Object?> json) => standardSerializers.deserializeWith(serializer, json) as T;

Map<String, Object?> variantJson(String id, {String price = '50000.0', String? name}) => {
      'id': id,
      'name': name,
      'sku': null,
      'barcode': null,
      'price': price,
      'list_price': null,
      'schedule_id': null,
    };

Map<String, Object?> menuItemJson(
  String id, {
  required String name,
  String categoryId = 'posmcat_1',
  List<String> groups = const [],
  bool soldOut = false,
  List<Map<String, Object?>>? variants,
}) =>
    {
      'id': id,
      'product_id': 'prod_$id',
      'name': name,
      'kind': 'single',
      'menu_category_id': categoryId,
      'kitchen_category': null,
      'cup_label': false,
      'show_components_on_kds': false,
      'position': 0,
      'active': true,
      'tax_category_id': null,
      'modifier_group_ids': groups,
      'components': <Object?>[],
      'image_url': null,
      'sold_out': soldOut,
      'variants': variants ?? [variantJson('variant_$id')],
    };

Map<String, Object?> groupJson(
  String id, {
  required String name,
  int min = 0,
  int max = 1,
  bool required = false,
  bool allowQuantity = false,
  required List<Map<String, Object?>> options,
}) =>
    {
      'id': id,
      'name': name,
      'min_select': min,
      'max_select': max,
      'allow_quantity': allowQuantity,
      'position': 0,
      'required': required,
      'options': options,
    };

Map<String, Object?> optionJson(String id, {required String name, String delta = '0.0', bool selected = false}) => {
      'id': id,
      'name': name,
      'price_delta': delta,
      'variant_id': null,
      'default_selected': selected,
      'position': 0,
      'active': true,
    };

Menu menu({required List<Map<String, Object?>> items, List<Map<String, Object?>> groups = const []}) =>
    parse(Menu.serializer, {
      'branch_id': 'posbranch_1',
      'currency': 'VND',
      'business_date': '2026-11-12',
      'module_enabled': true,
      'categories': [
        {'id': 'posmcat_1', 'name': 'Món chính', 'position': 0, 'color': null, 'active': true},
        {'id': 'posmcat_2', 'name': 'Đồ uống', 'position': 1, 'color': null, 'active': true},
      ],
      'items': items,
      'modifier_groups': groups,
      'schedules': <Object?>[],
      'favorites': <Object?>[],
      'etag': 'e1',
    });

Map<String, Object?> lineJson(
  String id, {
  String name = 'Phở bò',
  int quantity = 2,
  String sent = '0',
  String pending = '2',
  Map<String, Object?> kitchen = const {},
  int? course,
  String? courseStatus,
  int? seat,
}) =>
    {
      'id': id,
      'variant_id': 'variant_1',
      'name': name,
      'quantity': quantity,
      'price': '50000.0',
      'amount': '${50000 * quantity}.0',
      'sale_line_id': 'possline_$id',
      'kitchen_sent_quantity': sent,
      'pending_kitchen_quantity': pending,
      'row_version': 1,
      'kitchen_status': kitchen,
      'course': course,
      'course_status': courseStatus,
      'seat': seat,
    };

Workspace workspace({String id = 'posws_1', List<Map<String, Object?>> lines = const [], int revision = 3}) =>
    parse(Workspace.serializer, {
      'id': id,
      'revision': revision,
      'lease_generation': 1,
      'operational_status': 'editing',
      'service_mode': 'dine_in',
      'business_date': '2026-11-12',
      'resource': {'id': 'posres_5', 'name': 'Bàn 5', 'kind': 'table', 'area_id': 'posarea_1'},
      'guest_count': 3,
      'table_label': null,
      'line_items': lines,
      'totals': {'taxes': <Object?>[]},
    });

Map<String, Object?> tileJson(
  String id, {
  required String name,
  String state = 'available',
  String area = 'posarea_1',
  List<Map<String, Object?>> orders = const [],
  bool paymentRequested = false,
}) =>
    {
      'id': id,
      'area_id': area,
      'name': name,
      'kind': 'table',
      'capacity': 4,
      'shape': 'rect',
      'x': 0,
      'y': 0,
      'w': 1,
      'h': 1,
      'rotation': 0,
      'manual_status': 'available',
      'state': state,
      'guest_count': orders.isEmpty ? null : 2,
      'seated_minutes': orders.isEmpty ? null : 12,
      'subtotal': null,
      'currency': 'VND',
      'payment_requested': paymentRequested,
      'edited_after_prebill': false,
      'orders': orders,
    };

Map<String, Object?> orderJson(
  String id, {
  int pending = 0,
  int unsent = 0,
  bool paymentRequested = false,
}) =>
    {
      'id': id,
      'table_label': null,
      'guest_count': 2,
      'total': '100000.0',
      'revision': 1,
      'operational_status': 'editing',
      'payment_requested': paymentRequested,
      'prebilled': false,
      'edited_after_prebill': false,
      'pending_kitchen_items': pending,
      'unsent_kitchen_items': unsent,
    };

ResourceBoard boardOf(List<Map<String, Object?>> tiles) => parse(ResourceBoard.serializer, {
      'branch_id': 'posbranch_1',
      'server_now': '2026-11-12T12:00:00.000+07:00',
      'outside_operating_hours': false,
      'areas': [
        {'id': 'posarea_1', 'name': 'Tầng 1', 'position': 0, 'floor_width': 10, 'floor_height': 10},
        {'id': 'posarea_2', 'name': 'Sân', 'position': 1, 'floor_width': 10, 'floor_height': 10},
      ],
      'resources': tiles,
    });

Map<String, Object?> readyJson(String id, {String name = 'Phở bò', String status = 'ready', String workspaceId = 'posws_1'}) =>
    {
      'id': id,
      'name': name,
      'quantity': '2.0',
      'modifiers': <Object?>[],
      'status': status,
      'ready_at': '2026-11-12T12:00:00.000+07:00',
      'served_at': null,
      'station_name': 'Bếp',
      'workspace_id': workspaceId,
      'table_label': null,
      'resource_id': 'posres_5',
      'table_name': 'Bàn 5',
    };

ReadyFeed feed(List<Map<String, Object?>> items) => parse(ReadyFeed.serializer, {
      'branch_id': 'posbranch_1',
      'server_now': '2026-11-12T12:00:00.000+07:00',
      'area_id': null,
      'items': items,
    });

/// A [WaiterApi] that answers from memory and records what it was asked.
class FakeWaiterApi implements WaiterApi {
  FakeWaiterApi({Menu? menu, Workspace? workspace, ResourceBoard? board})
      : currentMenu = menu,
        current = workspace,
        board = board ?? boardOf(const []);

  Menu? currentMenu;
  Workspace? current;
  ResourceBoard board;
  ReadyFeed currentFeed = feed(const []);
  TablePins currentPins = TablePins();
  final calls = <String>[];

  /// Thrown by the next commands, in order; a null lets one through.
  final failures = <AppFailure?>[];

  Future<T> _answer<T>(String call, T Function() value) async {
    calls.add(call);
    if (failures.isNotEmpty) {
      final failure = failures.removeAt(0);
      if (failure != null) throw failure;
    }
    return value();
  }

  @override
  Future<ResourceBoard> tables(String branchId) => _answer('tables', () => board);

  @override
  Future<Menu> menu(String branchId) => _answer('menu', () => currentMenu!);

  @override
  Future<Workspace> workspace(String id) async => current!;

  @override
  Future<Workspace> open(String branchId, String resourceId,
          {required String editorId, int? guestCount, bool addOrder = false}) =>
      _answer('open:$resourceId:$guestCount:$addOrder', () => current!);

  @override
  Future<Workspace> append(String workspaceId, List<AppendItem> items, {required String batchId}) => _answer(
        'append:${items.map((item) => '${item.variantId}x${item.quantity}'
            '${item.modifiers?.map((pick) => '+${pick.optionId}').join() ?? ''}'
            '${item.course == null ? '' : '@c${item.course}'}${item.seat == null ? '' : 's${item.seat}'}'
            '${item.hold == true ? 'h' : ''}').join(',')}:$batchId',
        () => current!,
      );

  @override
  Future<Workspace> sendToKitchen(String workspaceId) => _answer('send:$workspaceId', () => current!);

  @override
  Future<Workspace> fireCourse(String workspaceId, int course) => _answer('fire:$workspaceId:$course', () => current!);

  @override
  Future<Workspace> voidSent(String workspaceId, String saleLineId,
          {required int quantity, required String reasonCode, String? note, String? approvalId}) =>
      _answer('void:$saleLineId:$quantity:$reasonCode:${approvalId ?? '-'}', () => current!);

  @override
  Future<Workspace> removeUnsent(String workspaceId, WorkspaceLine line) => _answer('remove:${line.id}', () => current!);

  @override
  Future<Workspace> requestPayment(String workspaceId) => _answer('payment:$workspaceId', () => current!);

  @override
  Future<PrebillOutcome> prebill(String workspaceId, {String? printerId}) => throw UnimplementedError();

  @override
  Future<ChecklistOutcome> checklist(String workspaceId, {String? printerId}) =>
      _answer('checklist:${printerId ?? '-'}', () => parse(ChecklistOutcome.serializer, {
            'document': {
              'title': 'PHIẾU KIỂM ĐỒ',
              'number': 'Bàn 5',
              'header': [
                {'kind': 'text', 'lines': ['2 x Phở bò', 'Đã ra 2 · Chưa ra 0']},
              ],
            },
            'print_job': null,
          }));

  @override
  Future<Workspace> claimLease(String workspaceId, String editorId) => _answer('lease', () => current!);

  @override
  Future<Workspace> move(Workspace workspace, {required String editorId, required String resourceId}) =>
      _answer('move:$resourceId', () => current!);

  @override
  Future<Workspace> merge(Workspace workspace, {required String editorId, required String targetWorkspaceId}) =>
      _answer('merge:$targetWorkspaceId', () => current!);

  @override
  Future<ReadyFeed> readyFeed({String? areaId}) => _answer('feed:${areaId ?? '-'}', () => currentFeed);

  @override
  Future<TablePins> pins() async => currentPins;

  @override
  Future<TablePins> pin(String resourceId, {required bool pinned}) =>
      _answer('pin:$resourceId:$pinned', () => currentPins = TablePins((b) => b.pinned.replace(pinned ? [resourceId] : <String>[])));

  @override
  Future<List<Printer>> printers(String branchId) async => const [];

  /// The branch's void reasons the fake answers; null as from an older server.
  List<String>? branchVoidReasons;

  @override
  Future<List<String>?> voidReasons(String branchId) async => branchVoidReasons;

  /// The modules the fake branch runs.
  Set<String> branchModules = const {};

  @override
  Future<Set<String>> modules(String branchId) async => branchModules;

  List<WorkspaceSummary> openTabs = const [];

  @override
  Future<List<WorkspaceSummary>> tabs(String branchId, {String? query}) => _answer(
        'tabs:${query ?? ''}',
        () => openTabs
            .where((tab) => (query ?? '').isEmpty || (tab.tabName ?? '').toLowerCase().contains(query!.toLowerCase()))
            .toList(),
      );

  @override
  Future<Workspace> openTab(String branchId, String name, {required String editorId}) =>
      _answer('open-tab:$name', () => current!);

  List<BottleKeep> keptBottles = const [];

  @override
  Future<List<BottleKeep>> bottles(String branchId, String query) =>
      _answer('bottles:$query', () => keptBottles.where((bottle) => bottle.code.contains(query)).toList());

  @override
  Future<BottleKeep> pour(String id, {required int levelPercent, int? ml, String? workspaceId, List<int>? photo}) =>
      _answer('pour:$id:$levelPercent:${ml ?? '-'}:${photo == null ? 'no-photo' : 'photo'}', () {
        final bottle = keptBottles.firstWhere((row) => row.id == id);
        return bottle.rebuild((b) => b
          ..levelPercent = levelPercent
          ..status = levelPercent == 0 ? BottleKeepStatusEnum.finished : BottleKeepStatusEnum.kept);
      });

  /// What the person signed in may do in the fake branch.
  Set<String> branchCapabilities = const {};

  @override
  Future<Set<String>> capabilities(String branchId) async => branchCapabilities;

  @override
  Future<TimedSessionCommand> startClock(String branchId, String resourceId,
          {required String editorId, String? workspaceId}) =>
      _answer('start-clock:$resourceId:${workspaceId ?? '-'}', () => clockCommand('postimed_new'));

  @override
  Future<TimedSessionCommand> stopClock(String sessionId) =>
      _answer('stop-clock:$sessionId', () => clockCommand(sessionId, status: 'stopped', amount: '100000.0'));

  @override
  Future<TimedSessionCommand> moveClock(String sessionId, String resourceId) =>
      _answer('move-clock:$sessionId:$resourceId', () => clockCommand(sessionId));

  @override
  Future<TimedSessionCommand> pauseClock(String sessionId) =>
      _answer('pause-clock:$sessionId', () => clockCommand(sessionId, status: 'paused'));

  @override
  Future<TimedSessionCommand> resumeClock(String sessionId) =>
      _answer('resume-clock:$sessionId', () => clockCommand(sessionId));

  @override
  Future<AttendantAssignment> serveRoom(String branchId, String resourceId, String staffId) =>
      _answer('serve:$resourceId:$staffId', () => parse(AttendantAssignment.serializer, {
            'id': 'posattendant_1',
            'branch_id': branchId,
            'resource_id': resourceId,
            'resource_name': 'P1',
            'timed_session_id': null,
            'staff': {'id': staffId, 'name': 'Lan'},
            'started_at': '2026-11-12T12:00:00.000+07:00',
            'ended_at': null,
            'minutes': 0,
            'business_date': '2026-11-12',
            'note': null,
          }));

  /// The person signed in to the fake branch.
  String? signedInStaffId;

  @override
  Future<String?> staffId(String branchId) async => signedInStaffId;
}

/// A clock of a room as the board shows it.
Map<String, Object?> timedJson(String id,
        {String workspaceId = 'posws_1',
        String status = 'running',
        String startedAt = '2026-11-12T11:20:00.000+07:00',
        String amount = '75000.0',
        int? playedSeconds,
        int? prepaidMinutes,
        bool pauseTooLong = false}) =>
    {
      'id': id,
      'workspace_id': workspaceId,
      'status': status,
      'started_at': startedAt,
      'stopped_at': status == 'stopped' ? '2026-11-12T12:00:00.000+07:00' : null,
      'planned_end_at': null,
      'paused_at': status == 'paused' ? '2026-11-12T11:50:00.000+07:00' : null,
      'prepaid_minutes': prepaidMinutes,
      'played_seconds': playedSeconds,
      'played_minutes': 40,
      'quote_amount': amount,
      'ending_soon': false,
      'package_ended': false,
      'pause_too_long': pauseTooLong,
    };

/// A room or billiard table on the board, with its clock.
Map<String, Object?> roomJson(
  String id, {
  required String name,
  String state = 'available',
  String kind = 'room',
  List<Map<String, Object?>> orders = const [],
  Map<String, Object?>? timed,
}) =>
    {
      ...tileJson(id, name: name, state: state, orders: orders),
      'kind': kind,
      'next_reservation': null,
      'buffet_ends_at': null,
      'timed': timed,
    };

/// A clock command's answer: the room's order and the clock.
TimedSessionCommand clockCommand(String id, {String status = 'running', String amount = '0.0'}) =>
    parse(TimedSessionCommand.serializer, {
      'workspace': {
        'id': 'posws_1',
        'revision': 4,
        'operational_status': 'editing',
        'service_mode': 'timed',
        'business_date': '2026-11-12',
        'totals': {'taxes': <Object?>[]},
      },
      'timed_session': {
        'id': id,
        'status': status,
        'resource_id': 'posres_1',
        'resource_name': 'P1',
        'started_at': '2026-11-12T11:20:00.000+07:00',
        'stopped_at': status == 'stopped' ? '2026-11-12T12:00:00.000+07:00' : null,
        'planned_end_at': null,
        'played_minutes': 40,
        'billed_minutes': 45,
        'amount': amount,
        'currency': 'VND',
        'quote_version': 1,
        'segments': <Object?>[],
        'quote': null,
      },
    });

Map<String, Object?> tabJson(String id, {required String name, String total = '250000.0'}) => {
      'id': id,
      'branch_id': 'posbranch_1',
      'revision': 2,
      'operational_status': 'editing',
      'service_mode': 'tab',
      'business_date': '2026-11-12',
      'order_number': 7,
      'guest_name': null,
      'tab_name': name,
      'resource': null,
      'opened_at': '2026-11-12T22:30:00.000+07:00',
      'total': total,
    };

Map<String, Object?> bottleJson(String id, {required String code, int level = 70}) => {
      'id': id,
      'branch_id': 'posbranch_1',
      'code': code,
      'status': 'kept',
      'level_percent': level,
      'variant_id': 'variant_hennessy',
      'product_name': 'Hennessy VSOP',
      'options_text': null,
      'customer': null,
      'guest_name': 'Anh Hùng',
      'phone': '0901234567',
      'kept_on': '2026-11-01',
      'expires_on': '2026-12-01',
      'source_order_id': null,
      'note': null,
      'revision': 1,
      'photo_url': null,
      'created_at': '2026-11-01T21:00:00.000+07:00',
      'closed_at': null,
    };

/// The app's localizations around a screen, in Vietnamese.
Widget localized(Widget home) => MaterialApp(
      locale: const Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );

/// Branch events a test sends by hand.
StreamController<Map<String, Object?>> eventSource() => StreamController<Map<String, Object?>>.broadcast();
