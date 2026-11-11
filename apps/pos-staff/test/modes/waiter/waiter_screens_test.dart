import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/core/realtime_provider.dart';
import 'package:parkviet_staff/modes/waiter/order_menu_screen.dart';
import 'package:parkviet_staff/modes/waiter/table_order_screen.dart';
import 'package:parkviet_staff/modes/waiter/waiter_context.dart';
import 'package:parkviet_staff/modes/waiter/waiter_screen.dart';
import 'package:parkviet_staff/modes/waiter/waiter_state.dart';

import 'waiter_fixtures.dart';

WaiterContext contextFor(FakeWaiterApi api, [Stream<Map<String, Object?>> events = const Stream.empty()]) => WaiterContext(
      api: api,
      branchId: 'posbranch_1',
      deviceId: 'posdev_1',
      editorId: 'editor-1',
      baseUrl: 'http://pos.test',
      events: events,
    );

void main() {
  testWidgets('orders a dish with a required option and sends it with the kitchen in one go', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeWaiterApi(
      workspace: workspace(lines: [lineJson('l1')]),
      menu: menu(
        items: [
          menuItemJson('mi_tea', name: 'Trà sữa', categoryId: 'posmcat_2', groups: ['g_size']),
          menuItemJson('mi_pho', name: 'Phở bò'),
          menuItemJson('mi_bun', name: 'Bún chả', soldOut: true),
        ],
        groups: [
          groupJson('g_size', name: 'Cỡ', min: 1, max: 1, required: true, options: [
            optionJson('o_m', name: 'Vừa'),
            optionJson('o_l', name: 'Lớn', delta: '10000.0'),
          ]),
        ],
      ),
    );
    final waiter = contextFor(api);
    addTearDown(waiter.dispose);
    AddOutcome? outcome;
    await tester.pumpWidget(localized(Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async => outcome = await Navigator.of(context).push<AddOutcome>(MaterialPageRoute(
            builder: (_) => OrderMenuScreen(waiter: waiter, workspaceId: 'posws_1', title: 'Bàn 5'),
          )),
          child: const Text('go'),
        ),
      ),
    )));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    // A sold-out dish is dimmed and stays out of the cart.
    await tester.tap(find.byKey(const Key('dish-mi_bun')));
    await tester.pumpAndSettle();
    expect(find.text('Món này đã hết.'), findsOneWidget);
    expect(find.byKey(const Key('cart-add')), findsNothing);

    await tester.tap(find.byKey(const Key('category-posmcat_2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dish-mi_pho')), findsNothing);
    await tester.tap(find.byKey(const Key('dish-mi_tea')));
    await tester.pumpAndSettle();
    final add = find.byKey(const Key('modifier-add'));
    expect(tester.widget<FilledButton>(add).onPressed, isNull, reason: 'the size is required');
    await tester.tap(find.byKey(const Key('option-o_l')));
    await tester.enterText(find.byKey(const Key('modifier-note')), 'Ít đá');
    await tester.pumpAndSettle();
    expect(find.text('Thêm · 60.000đ'), findsOneWidget);
    await tester.tap(add);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('category-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dish-mi_pho')));
    await tester.pumpAndSettle();
    expect(find.text('2 món · 110.000đ'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cart-add-send')));
    await tester.pumpAndSettle();
    expect(api.calls.where((call) => call.startsWith('append:')).single,
        startsWith('append:variant_mi_teax1+o_l,variant_mi_phox1:'));
    expect(api.calls.last, 'send:posws_1');
    expect(outcome?.sent, isTrue);
  });

  testWidgets('keeps the cart and its batch when adding fails, so trying again adds it once', (tester) async {
    final api = FakeWaiterApi(workspace: workspace(), menu: menu(items: [menuItemJson('mi_pho', name: 'Phở bò')]));
    final waiter = contextFor(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(OrderMenuScreen(waiter: waiter, workspaceId: 'posws_1', title: 'Bàn 5')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dish-mi_pho')));
    await tester.pumpAndSettle();

    api.failures.add(const AppFailure.timeout());
    await tester.tap(find.byKey(const Key('cart-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cart-add')));
    await tester.pumpAndSettle();
    final appends = api.calls.where((call) => call.startsWith('append:')).toList();
    expect(appends, hasLength(2));
    expect(appends.first, appends.last, reason: 'the retry carries the same batch id');
  });

  testWidgets('shows the kitchen state of each line and voids a sent dish once a manager approves', (tester) async {
    final events = eventSource();
    addTearDown(events.close);
    final api = FakeWaiterApi(
      workspace: workspace(lines: [
        lineJson('l1', sent: '2', pending: '0', kitchen: {'preparing': '1.0', 'ready': '1.0'}),
        lineJson('l2', name: 'Trà đá', quantity: 1, pending: '1'),
      ]),
    );
    final waiter = contextFor(api, events.stream);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(TableOrderScreen(waiter: waiter, workspaceId: 'posws_1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 đang làm · 1 xong'), findsOneWidget);
    expect(find.textContaining('1 chưa báo bếp'), findsOneWidget);
    expect(find.text('Báo bếp (1)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('line-l1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('line-void-l1')));
    await tester.pumpAndSettle();
    api.failures.add(const AppFailure.conflict(reason: 'approval_required'));
    await tester.tap(find.byKey(const Key('void-confirm')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('void-waiting-approval')), findsOneWidget);
    expect(api.calls.last, 'void:possline_l1:1:khach_doi_y:-');

    // The manager grants it elsewhere; the grant fills the code and the
    // void goes through by itself.
    events.add({
      'event': 'approval.requested',
      'id': 'posappr_9',
      'refs': {'workspace_id': 'posws_1'},
    });
    await tester.pumpAndSettle();
    expect(api.calls.last, 'void:possline_l1:1:khach_doi_y:posappr_9');
    expect(find.byKey(const Key('void-waiting-approval')), findsNothing);
    expect(find.text('Đã hủy món.'), findsOneWidget);
  });

  testWidgets('offers the branch void reasons it read, with "other" last and its own codes as words', (tester) async {
    final api = FakeWaiterApi(workspace: workspace(lines: [lineJson('l1', sent: '1', pending: '0')]))
      ..branchVoidReasons = ['het_mon', 'mon_nguoi'];
    final waiter = contextFor(api);
    addTearDown(waiter.dispose);
    await waiter.loadVoidReasons();
    await tester.pumpWidget(localized(TableOrderScreen(waiter: waiter, workspaceId: 'posws_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('line-l1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('line-void-l1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('void-reason-khach_doi_y')), findsNothing);
    expect(find.text('Hết món'), findsOneWidget);
    expect(find.text('Mon nguoi'), findsOneWidget);
    expect(find.byKey(const Key('void-reason-khac')), findsOneWidget);
    await tester.tap(find.byKey(const Key('void-confirm')));
    await tester.pumpAndSettle();
    expect(api.calls.last, 'void:possline_l1:1:het_mon:-');
  });
  testWidgets('a line changed by someone else says so and reads the order again', (tester) async {
    final api = FakeWaiterApi(workspace: workspace(lines: [lineJson('l2', name: 'Trà đá', quantity: 1, pending: '1')]));
    final waiter = contextFor(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(TableOrderScreen(waiter: waiter, workspaceId: 'posws_1')));
    await tester.pumpAndSettle();

    api.failures.add(const AppFailure.conflict(reason: 'line_changed'));
    await tester.tap(find.byKey(const Key('line-l2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('line-remove-l2')));
    await tester.pumpAndSettle();
    expect(find.text('Món này vừa được người khác sửa. Đã tải lại đơn.'), findsOneWidget);
  });

  testWidgets('prints the checklist as text when the branch has no printer for it', (tester) async {
    final api = FakeWaiterApi(workspace: workspace(lines: [lineJson('l1', sent: '2', pending: '0')]));
    final waiter = contextFor(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(TableOrderScreen(waiter: waiter, workspaceId: 'posws_1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('order-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('action-checklist')));
    await tester.pumpAndSettle();
    expect(api.calls.last, 'checklist:-');
    expect(find.textContaining('Đã ra 2 · Chưa ra 0'), findsOneWidget);
  });

  testWidgets('filters the tables, opens a free one with the guest count and pins another', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeWaiterApi(
      workspace: workspace(),
      menu: menu(items: const []),
      board: boardOf([
        tileJson('posres_1', name: 'Bàn 1'),
        tileJson('posres_2', name: 'Bàn 2', state: 'ordered', orders: [orderJson('posws_2', pending: 2)]),
        tileJson('posres_3', name: 'Sân 1', area: 'posarea_2'),
      ]),
    );
    final waiter = contextFor(api);
    addTearDown(waiter.dispose);
    final ready = ReadyWatcher(api: api);
    addTearDown(ready.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [realtimeProvider.overrideWithValue(null)],
      child: localized(TableBoard(waiter: waiter, ready: ready, onFollow: (_) async {})),
    ));
    await tester.pumpAndSettle();

    expect(find.text('2 món chờ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('filter-waiting')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('table-posres_1')), findsNothing);
    expect(find.byKey(const Key('table-posres_2')), findsOneWidget);
    await tester.tap(find.byKey(const Key('filter-all')));
    await tester.tap(find.byKey(const Key('area-posarea_2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('table-posres_1')), findsNothing);
    expect(find.byKey(const Key('table-posres_3')), findsOneWidget);
    await tester.tap(find.byKey(const Key('area-all')));
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('table-posres_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tile-pin-posres_2')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('pin:posres_2:true'));
    await tester.scrollUntilVisible(find.byKey(const Key('filter-mine')), 200,
        scrollable: find.descendant(of: find.byKey(const Key('table-filters')), matching: find.byType(Scrollable)));
    await tester.tap(find.byKey(const Key('filter-mine')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('table-posres_2')), findsOneWidget);
    expect(find.byKey(const Key('table-posres_1')), findsNothing);
    await tester.scrollUntilVisible(find.byKey(const Key('filter-all')), -200,
        scrollable: find.descendant(of: find.byKey(const Key('table-filters')), matching: find.byType(Scrollable)));
    await tester.tap(find.byKey(const Key('filter-all')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('table-posres_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guest-key-4')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('guest-count')), findsOneWidget);
    await tester.tap(find.byKey(const Key('guest-confirm')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('open:posres_1:4:false'));
    expect(find.byType(TableOrderScreen), findsOneWidget);
  });
}
