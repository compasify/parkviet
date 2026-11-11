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

Map<String, Object?> orderJson(String id, {int pending = 0, bool paymentRequested = false}) => {
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
    };

ResourceBoard boardOf(List<Map<String, Object?>> tiles) => parse(ResourceBoard.serializer, {
      'branch_id': 'posbranch_1',
      'server_now': '2026-11-12T12:00:00.000+07:00',
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
}

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
