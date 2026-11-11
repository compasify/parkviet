import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/modes/kds/kds_grouping.dart';
import 'package:pos_api/pos_api.dart';

import 'kds_fixtures.dart';

void main() {
  final station = standardSerializers.deserializeWith(KitchenStation.serializer, stationJson(warn: 5, late: 10))!;

  test('colours a ticket by its wait against the station thresholds', () {
    final sent = ticket(ticketJson('t1', sentAt: '2026-11-11T12:00:00.000+07:00'));
    final at = DateTime.parse('2026-11-11T12:00:00.000+07:00');
    expect(urgencyOf(sent, station, at.add(const Duration(minutes: 4, seconds: 59))), TicketUrgency.normal);
    expect(urgencyOf(sent, station, at.add(const Duration(minutes: 5))), TicketUrgency.warn);
    expect(urgencyOf(sent, station, at.add(const Duration(minutes: 10))), TicketUrgency.late);
    // Without its station, the defaults: 8 and 15 minutes.
    expect(urgencyOf(sent, null, at.add(const Duration(minutes: 9))), TicketUrgency.warn);
  });

  test('labels waits and quantities the way the kitchen reads them', () {
    final at = DateTime.utc(2026, 11, 11, 5);
    expect(elapsedLabel(at, at.add(const Duration(minutes: 3, seconds: 7))), '03:07');
    expect(elapsedLabel(at, at.add(const Duration(hours: 1, minutes: 2, seconds: 3))), '1:02:03');
    expect(elapsedLabel(at, at.subtract(const Duration(seconds: 5))), '00:00');
    expect(quantityLabel('2.0'), '2');
    expect(quantityLabel('1.5'), '1.5');
  });

  test('sums open dishes by name and options across tickets, leaving finished ones out', () {
    final tickets = [
      ticket(ticketJson('t1', sentAt: '2026-11-11T12:00:00.000+07:00', items: [
        itemJson('a', name: 'Trà sữa (L)', quantity: '2.0', modifiers: [
          {'name': 'Ít đá', 'group_name': 'Đá', 'quantity': 1},
        ]),
        itemJson('b', name: 'Phở bò'),
      ])),
      ticket(ticketJson('t2', sequence: 2, sentAt: '2026-11-11T12:01:00.000+07:00', items: [
        itemJson('c', name: 'Trà sữa (L)', modifiers: [
          {'name': 'Ít đá', 'group_name': 'Đá', 'quantity': 1},
        ]),
        itemJson('d', name: 'Trà sữa (L)'),
        itemJson('e', name: 'Phở bò', status: 'ready'),
      ])),
    ];
    final tallies = tallyByItem(tickets);
    expect(tallies.map((row) => '${quantityLabel('${row.quantity}')} ${row.name} ${row.options}'),
        ['3 Trà sữa (L) Ít đá', '1 Phở bò ', '1 Trà sữa (L) ']);
    expect(tallies.first.ticketSequences, {1, 2});
  });

  test('groups tickets by table, call number or order, the longest waiting first', () {
    final tickets = [
      ticket(ticketJson('t1', sentAt: '2026-11-11T12:05:00.000+07:00', workspaceId: 'posws_b')),
      ticket(ticketJson('t2', sentAt: '2026-11-11T12:00:00.000+07:00', workspaceId: 'posws_a',
          header: {'service_mode': 'dine_in', 'table': 'Bàn 4'})),
      ticket(ticketJson('t3', sequence: 2, sentAt: '2026-11-11T12:06:00.000+07:00', workspaceId: 'posws_a',
          header: {'service_mode': 'dine_in', 'table': 'Bàn 4'})),
    ];
    final groups = groupByOrder(tickets);
    expect(groups.map((group) => group.label), ['Bàn 4', null]);
    expect(groups.first.tickets.map((row) => row.id), ['t2', 't3']);
  });
}
