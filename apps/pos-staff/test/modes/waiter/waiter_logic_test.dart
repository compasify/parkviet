import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/menu/modifier_sheet.dart';
import 'package:parkviet_staff/modes/waiter/void_reasons.dart';
import 'package:parkviet_staff/modes/waiter/waiter_cart.dart';
import 'package:parkviet_staff/modes/waiter/waiter_state.dart';
import 'package:pos_api/pos_api.dart';

import 'waiter_fixtures.dart';

void main() {
  final groups = [
    parse(ModifierGroup.serializer, groupJson('g_size', name: 'Cỡ', min: 1, max: 1, required: true, options: [
      optionJson('o_m', name: 'Vừa'),
      optionJson('o_l', name: 'Lớn', delta: '10000.0'),
    ])),
    parse(ModifierGroup.serializer, groupJson('g_top', name: 'Thêm', max: 3, allowQuantity: true, options: [
      optionJson('o_pearl', name: 'Trân châu', delta: '5000.0'),
      optionJson('o_jelly', name: 'Thạch', delta: '5000.0'),
    ])),
  ];

  group('void reasons', () {
    test('are the branch ones, or the defaults, once each, with "other" always last', () {
      expect(voidReasonChoices(null), [...defaultVoidReasons, voidOther]);
      expect(voidReasonChoices(['het_mon', 'khac', 'het_mon', 'mon_nguoi']), ['het_mon', 'mon_nguoi', voidOther]);
      expect(voidReasonChoices(const []), [voidOther]);
    });
  });

  group('modifier rules', () {
    test('a required group takes at least one pick, as the server does', () {
      final required = groups.first;
      expect(minimumOf(required), 1);
      expect(invalidGroups(groups, {}), [required]);
      expect(invalidGroups(groups, {'o_m': 1}), isEmpty);
    });

    test('a quantity group counts units against its maximum', () {
      expect(countOf(groups.last, {'o_pearl': 2, 'o_jelly': 1}), 3);
      expect(invalidGroups(groups, {'o_m': 1, 'o_pearl': 3, 'o_jelly': 1}), [groups.last]);
    });

    test('the price of one adds the options with their quantities', () {
      final item = parse(MenuItem.serializer, menuItemJson('mi_1', name: 'Trà sữa', groups: ['g_size', 'g_top']));
      final choice = ModifierChoice(
        variant: item.variants.first,
        options: [(groups.first.options.last, 1), (groups.last.options.first, 2)],
        quantity: 2,
      );
      expect(choice.unitPrice, 50000 + 10000 + 2 * 5000);
      expect(moneyLabel(choice.unitPrice * choice.quantity), '140.000đ');
      expect(groupsOf(item, groups).map((group) => group.id), ['g_size', 'g_top']);
    });
  });

  group('cart', () {
    test('sends its lines with options and note, and renews the batch when it changes', () {
      final item = parse(MenuItem.serializer, menuItemJson('mi_1', name: 'Trà sữa', groups: ['g_size']));
      final cart = WaiterCart();
      final first = cart.batchId;
      cart.add(
        item,
        ModifierChoice(variant: item.variants.first, options: [(groups.first.options.first, 1)], note: 'Ít đá', quantity: 2),
      );
      final added = cart.batchId;
      expect(added, isNot(first), reason: 'a changed cart is a new batch');

      final items = cart.toAppendItems();
      expect(items.single.variantId, 'variant_mi_1');
      expect(items.single.quantity, 2);
      expect(items.single.note, 'Ít đá');
      expect(items.single.modifiers!.single.optionId, 'o_m');
      expect(cart.batchId, added, reason: 'retrying the same cart keeps its batch');

      cart.setQuantity(cart.lines.single.key, 0);
      expect(cart.isEmpty, isTrue);
      expect(cart.batchId, isNot(added));
    });
  });

  group('table filters', () {
    final free = parse(ResourceBoardTile.serializer, tileJson('t1', name: 'Bàn 1'));
    final waiting = parse(
      ResourceBoardTile.serializer,
      tileJson('t2', name: 'Bàn 2', state: 'ordered', orders: [orderJson('w2', pending: 2)]),
    );
    final paying = parse(
      ResourceBoardTile.serializer,
      tileJson('t3', name: 'Bàn 3', state: 'payment_requested', orders: [orderJson('w3', paymentRequested: true)]),
    );

    test('match free, seated, waiting, payment and mine', () {
      List<String> shown(TableFilter filter, [Set<String> mine = const {}]) =>
          [free, waiting, paying].where((tile) => tableMatches(tile, filter, mine)).map((tile) => tile.id).toList();

      expect(shown(TableFilter.all), ['t1', 't2', 't3']);
      expect(shown(TableFilter.free), ['t1']);
      expect(shown(TableFilter.seated), ['t2', 't3']);
      expect(shown(TableFilter.waiting), ['t2']);
      expect(shown(TableFilter.payment), ['t3']);
      expect(shown(TableFilter.mine, {'t3'}), ['t3']);
    });
  });

  group('ready watcher', () {
    test('announces a dish once, after the first fetch, and keeps counting what is ready', () async {
      final api = FakeWaiterApi()..currentFeed = feed([readyJson('a')]);
      final announced = <String>[];
      final events = eventSource();
      final watcher = ReadyWatcher(api: api, onAnnounce: (notice) => announced.add(notice.item.id))
        ..start(events: events.stream);
      addTearDown(watcher.dispose);
      await pumpEventQueue();
      expect(announced, isEmpty, reason: 'what was ready before the screen opened does not ring');
      expect(watcher.ready.value.map((item) => item.id), ['a']);

      api.currentFeed = feed([readyJson('b', name: 'Bún chả'), readyJson('a')]);
      events.add({'event': 'kitchen_ticket.updated', 'id': 'poskt_1'});
      await pumpEventQueue();
      expect(announced, ['b']);
      expect(watcher.notice.value!.table, 'Bàn 5');

      events.add({'event': 'kitchen_ticket.updated', 'id': 'poskt_1'});
      await pumpEventQueue();
      expect(announced, ['b'], reason: 'the same dish rings once');

      await watcher.follow('posarea_1');
      expect(api.calls.last, 'feed:posarea_1');
      await events.close();
    });
  });
}
