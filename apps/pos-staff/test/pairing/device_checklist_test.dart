import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/app_mode.dart';
import 'package:parkviet_staff/pairing/device_checklist.dart';
import 'package:pos_api/pos_api.dart';

import '../modes/kds/kds_fixtures.dart';
import '../modes/waiter/waiter_fixtures.dart';

KitchenStation station(String id, String name, {String? printer}) => standardSerializers.deserializeWith(
  KitchenStation.serializer,
  {...stationJson(id: id, name: name), 'printer_id': printer == null ? null : 'posprn_1', 'printer_name': printer},
)!;

DeviceStaffMember member(String id, {required bool pin}) =>
    standardSerializers.deserializeWith(DeviceStaffMember.serializer, {'id': id, 'name': 'Lan', 'pin_set': pin})!;

void main() {
  group('device checklist', () {
    test('a kitchen screen needs its station and that station\'s printer', () {
      final stations = [station('s1', 'Bếp', printer: 'Máy in bếp'), station('s2', 'Bar')];
      final ready = checklistItems(mode: AppMode.kds, stationId: 's1', stations: stations);
      expect(ready.map((item) => (item.kind, item.ok, item.name)), [
        (ChecklistKind.station, true, 'Bếp'),
        (ChecklistKind.printer, true, 'Máy in bếp'),
      ]);
      final bar = checklistItems(mode: AppMode.expo, stationId: 's2', stations: stations);
      expect(bar.map((item) => item.ok), [true, false]);
      final none = checklistItems(mode: AppMode.kds, stations: stations);
      expect(none.map((item) => item.ok), [false, false]);
    });

    test('a waiter phone needs someone with a PIN; a print station needs nothing more', () {
      final staff = [member('m1', pin: true), member('m2', pin: false), member('m3', pin: true)];
      final waiter = checklistItems(mode: AppMode.waiter, staff: staff).single;
      expect((waiter.kind, waiter.ok, waiter.count), (ChecklistKind.staff, true, 2));
      expect(checklistItems(mode: AppMode.waiter, staff: [member('m2', pin: false)]).single.ok, isFalse);
      expect(checklistItems(mode: AppMode.printStation), isEmpty);
    });

    testWidgets('shows what is ready and what is not, and starting closes it', (tester) async {
      final container = ProviderContainer(
        overrides: [
          deviceChecklistProvider.overrideWith(
            (ref) async => const [
              ChecklistItem(ChecklistKind.station, ok: true, name: 'Bếp'),
              ChecklistItem(ChecklistKind.printer, ok: false),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(deviceChecklistPendingProvider.notifier).open();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: localized(const DeviceChecklistScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Đã chọn: Bếp'), findsOneWidget);
      expect(find.textContaining('Trạm chưa có máy in'), findsOneWidget);
      await tester.tap(find.byKey(const Key('checklist-start')));
      expect(container.read(deviceChecklistPendingProvider), isFalse);
    });
  });
}
