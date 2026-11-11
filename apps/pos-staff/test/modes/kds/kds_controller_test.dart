import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/core/realtime.dart';
import 'package:parkviet_staff/modes/kds/kds_grouping.dart';
import 'package:parkviet_staff/modes/kds/kds_repository.dart';

import 'kds_fixtures.dart';

const serverNow = '2026-11-11T12:10:00.000+07:00';

void main() {
  late FakeKitchenApi api;
  late StreamController<Map<String, Object?>> events;
  late StreamController<void> subscribed;
  late ValueNotifier<RealtimeStatus> status;
  late int chimes;

  KdsController controller({Duration poll = const Duration(seconds: 5), DateTime Function()? deviceNow}) => KdsController(
        api: api,
        stationIds: ['poskstation_1'],
        pollInterval: poll,
        onNewTicket: () => chimes++,
        deviceNow: deviceNow,
      )..start(events: events.stream, subscribed: subscribed.stream, status: status);

  setUp(() {
    api = FakeKitchenApi(board(serverNow: serverNow, open: [ticketJson('t1', sentAt: '2026-11-11T12:00:00.000+07:00')]));
    events = StreamController.broadcast();
    subscribed = StreamController.broadcast();
    status = ValueNotifier(RealtimeStatus.connected);
    chimes = 0;
  });

  tearDown(() async {
    await events.close();
    await subscribed.close();
  });

  test('loads the board of its station and runs the clock on the server time', () async {
    final local = DateTime.parse('2026-11-11T05:00:00.000Z');
    final kds = controller(deviceNow: () => local);
    await pumpEventQueue();

    expect(api.calls.first, 'board:poskstation_1');
    expect(kds.state.value.board!.open.single.id, 't1');
    expect(kds.state.value.live, isTrue);
    // The device clock is 10 minutes behind the server.
    expect(kds.clock.now(local), DateTime.parse(serverNow));
    expect(elapsedLabel(kds.state.value.board!.open.single.sentAt, kds.clock.now(local)), '10:00');
    await kds.dispose();
  });

  test('fetches again on a kitchen event and on every resubscription, and chimes for a new ticket only', () async {
    final kds = controller();
    await pumpEventQueue();
    final before = api.calls.length;

    events.add({'event': 'menu.sold_out'});
    await pumpEventQueue();
    expect(api.calls.length, before);

    api.current = board(serverNow: serverNow, open: [
      ticketJson('t1', sentAt: '2026-11-11T12:00:00.000+07:00'),
      ticketJson('t2', sentAt: '2026-11-11T12:09:00.000+07:00', sequence: 2),
    ]);
    events.add({'event': 'kitchen_ticket.updated', 'id': 't2'});
    await pumpEventQueue();
    expect(kds.state.value.board!.open.map((row) => row.id), ['t1', 't2']);
    expect(chimes, 1);

    subscribed.add(null);
    await pumpEventQueue();
    expect(api.calls.length, before + 2);
    expect(chimes, 1, reason: 'the same tickets again are not new');
    await kds.dispose();
  });

  test('polls while the socket is down, keeps the last board on a failure and stops polling once live', () async {
    status.value = RealtimeStatus.disconnected;
    final kds = controller(poll: const Duration(milliseconds: 20));
    await pumpEventQueue();
    expect(kds.state.value.live, isFalse);
    final synced = kds.state.value.lastSync;
    expect(synced, isNotNull);

    api.boardFailures.add(const AppFailure.unreachable());
    final first = api.calls.length;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(api.calls.length, greaterThan(first));
    expect(kds.state.value.board, isNotNull, reason: 'the last board stays on screen');

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(api.calls.length, greaterThan(first + 1));
    expect(kds.state.value.failure, isNull, reason: 'a later fetch worked');
    expect(kds.state.value.lastSync!.isBefore(synced!), isFalse);

    status.value = RealtimeStatus.connected;
    await pumpEventQueue();
    final live = api.calls.length;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(api.calls.length, live, reason: 'no polling with the socket up');
    expect(kds.state.value.live, isTrue);
    await kds.dispose();
  });

  test('shows the failure and goes offline when a fetch fails', () async {
    api.boardFailures.add(const AppFailure.unreachable());
    final kds = controller();
    await pumpEventQueue();
    expect(kds.state.value.failure, isA<UnreachableFailure>());
    expect(kds.state.value.live, isFalse);
    expect(kds.state.value.lastSync, isNull);
    await kds.dispose();
  });
  test('a burst of events costs one more fetch, not one per event', () async {
    final kds = controller();
    await pumpEventQueue();
    final before = api.calls.length;
    api.holdBoard = Completer();
    unawaited(kds.refresh());
    for (var i = 0; i < 5; i++) {
      events.add({'event': 'kitchen_ticket.updated'});
    }
    await pumpEventQueue();
    api.holdBoard!.complete();
    api.holdBoard = null;
    await pumpEventQueue();
    expect(api.calls.length, before + 2);
    await kds.dispose();
  });

  test('puts the answer of an action on the board at once', () async {
    final kds = controller();
    await pumpEventQueue();
    final item = kds.state.value.board!.open.single.items.single;

    api.actionResults.add(ticket(ticketJson('t1',
        sentAt: '2026-11-11T12:00:00.000+07:00', done: true, items: [itemJson(item.id, status: 'ready')])));
    api.current = board(serverNow: serverNow, done: [
      ticketJson('t1', sentAt: '2026-11-11T12:00:00.000+07:00', done: true, items: [itemJson(item.id, status: 'ready')]),
    ]);
    final failure = await kds.act(item, KitchenAction.ready);
    expect(failure, isNull);
    expect(api.calls, contains('ready:${item.id}'));
    expect(kds.state.value.board!.open, isEmpty);
    expect(kds.state.value.board!.done.single.id, 't1');
    await kds.dispose();
  });
}
