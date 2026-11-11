import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/modes/waiter/bottle_pour_screen.dart';
import 'package:parkviet_staff/modes/waiter/tab_list_screen.dart';
import 'package:parkviet_staff/modes/waiter/waiter_context.dart';
import 'package:pos_api/pos_api.dart';

import 'waiter_fixtures.dart';

WaiterContext barContext(FakeWaiterApi api) => WaiterContext(
      api: api,
      branchId: 'posbranch_1',
      deviceId: 'posdev_1',
      editorId: 'editor-1',
      baseUrl: 'http://pos.test',
    );

void main() {
  testWidgets('finds an open tab by name and opens a new one with only a name', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeWaiterApi(workspace: workspace(id: 'posws_tab'), menu: menu(items: [menuItemJson('mi_beer', name: 'Bia')]))
      ..openTabs = [
        parse(WorkspaceSummary.serializer, tabJson('posws_a', name: 'Anh Nam')),
        parse(WorkspaceSummary.serializer, tabJson('posws_b', name: 'Nhóm sinh nhật', total: '1200000.0')),
      ];
    final waiter = barContext(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(TabListScreen(waiter: waiter)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tab-posws_a')), findsOneWidget);
    expect(find.text('1.200.000đ'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('tab-search')), 'nam');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(api.calls, contains('tabs:nam'));
    expect(find.byKey(const Key('tab-posws_b')), findsNothing);

    await tester.tap(find.byKey(const Key('tab-open')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tab-name')), 'Chị Lan');
    await tester.tap(find.byKey(const Key('tab-name-confirm')));
    await tester.pump();
    expect(api.calls, contains('open-tab:Chị Lan'));
  });

  testWidgets('says why a tab name is refused', (tester) async {
    final api = FakeWaiterApi(workspace: workspace())
      ..failures.addAll([null, const AppFailure.conflict(reason: 'tab_name_taken')]);
    final waiter = barContext(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(TabListScreen(waiter: waiter)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-open')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tab-name')), 'Anh Nam');
    await tester.tap(find.byKey(const Key('tab-name-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Đã có tab đang mở với tên này.'), findsOneWidget);
  });

  testWidgets('pours from a kept bottle found by its code', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakeWaiterApi()..keptBottles = [parse(BottleKeep.serializer, bottleJson('posbk_1', code: 'K7PQ2M'))];
    final waiter = barContext(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(BottlePourScreen(waiter: waiter, scanner: false)));

    await tester.enterText(find.byKey(const Key('bottle-code')), 'k7pq2m');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(api.calls, contains('bottles:K7PQ2M'));
    expect(find.text('Anh Hùng · 0901234567 · Còn 70%'), findsOneWidget);

    final slider = tester.widget<Slider>(find.byKey(const Key('bottle-level')));
    slider.onChanged!(40);
    await tester.pump();
    await tester.enterText(find.byKey(const Key('bottle-ml')), '120');
    await tester.tap(find.byKey(const Key('bottle-pour')));
    await tester.pumpAndSettle();
    expect(api.calls, contains('pour:posbk_1:40:120:no-photo'));
    expect(find.text('Đã rót, chai còn 40%.'), findsOneWidget);
  });

  testWidgets('says when no kept bottle has the code', (tester) async {
    final api = FakeWaiterApi();
    final waiter = barContext(api);
    addTearDown(waiter.dispose);
    await tester.pumpWidget(localized(BottlePourScreen(waiter: waiter, scanner: false)));
    await tester.enterText(find.byKey(const Key('bottle-code')), 'ZZZZZZ');
    await tester.tap(find.byKey(const Key('bottle-find')));
    await tester.pumpAndSettle();
    expect(find.text('Không thấy chai gửi với mã này.'), findsOneWidget);
  });
}
