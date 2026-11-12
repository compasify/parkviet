import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/l10n/app_localizations.dart';
import 'package:parkviet_staff/modes/kiosk/kiosk_api.dart';
import 'package:parkviet_staff/modes/kiosk/kiosk_flow.dart';
import 'package:parkviet_staff/modes/kiosk/kiosk_screen.dart';
import 'package:pos_api/pos_api.dart';

T parse<T>(Serializer<T> serializer, Map<String, Object?> json) =>
    standardSerializers.deserializeWith(serializer, json) as T;

Map<String, Object?> stateJson({
  bool open = true,
  String? reason,
  int idle = 60,
  bool vietqr = true,
}) => {
  'open': open,
  'reason': reason,
  'branch': {'id': 'posbranch_1', 'name': 'Quận 1'},
  'register': {'id': 'posregister_1', 'name': 'Kiosk 1'},
  'currency': 'VND',
  'idle_seconds': idle,
  'qr_timeout_seconds': 180,
  'kitchen_before_payment': false,
  'payments': {'vietqr': open && vietqr, 'counter': true},
};

Map<String, Object?> menuJson() => {
  'currency': 'VND',
  'etag': 'abc',
  'categories': [
    {'id': 'posmcat_1', 'name': 'Cà phê', 'position': 0, 'color': null},
  ],
  'items': [
    {
      'id': 'posmenuitem_1',
      'name': 'Cà phê sữa',
      'kind': 'single',
      'menu_category_id': 'posmcat_1',
      'position': 0,
      'image_url': null,
      'sold_out': false,
      'modifier_group_ids': <String>[],
      'components': <Object?>[],
      'variants': [
        {
          'id': 'variant_1',
          'name': null,
          'price': '30000.0',
          'price_label': null,
        },
      ],
    },
    {
      'id': 'posmenuitem_2',
      'name': 'Bánh mì',
      'kind': 'single',
      'menu_category_id': 'posmcat_1',
      'position': 1,
      'image_url': null,
      'sold_out': true,
      'modifier_group_ids': <String>[],
      'components': <Object?>[],
      'variants': [
        {
          'id': 'variant_2',
          'name': null,
          'price': '20000.0',
          'price_label': null,
        },
      ],
    },
  ],
  'modifier_groups': <Object?>[],
};

Map<String, Object?> orderJson({
  required String status,
  int? callNumber,
  String? paymentState,
  DateTime? expiresAt,
}) => {
  'id': 'posworkspace_1',
  'status': status,
  'call_number': callNumber,
  'order_number': 'R100',
  'currency': 'VND',
  'total': '60000.0',
  'item_total': '60000.0',
  'lines': [
    {
      'name': 'Cà phê sữa',
      'quantity': '2.0',
      'unit_price': '30000.0',
      'amount': '60000.0',
      'note': null,
      'modifiers': <Object?>[],
    },
  ],
  'payment': paymentState == null
      ? null
      : {
          'kind': 'vietqr',
          'attempt_id': 'postender_1',
          'amount': '60000.0',
          'state': paymentState,
          'expires_at':
              (expiresAt ?? DateTime.now().add(const Duration(minutes: 3)))
                  .toUtc()
                  .toIso8601String(),
          'qr': paymentState == 'received'
              ? null
              : {
                  'qr_url': 'https://qr.invalid/x.png',
                  'bank_name': 'Vietcombank',
                  'account_number': '0123456789',
                  'account_name': 'PARK VIET',
                  'transfer_note': 'PV100',
                },
        },
  'device_id': 'posdevice_1',
};

KioskOrder kioskOrder(Map<String, Object?> json) =>
    parse(KioskOrder.serializer, json);

class FakeKioskApi implements KioskApi {
  KioskState currentState = parse(KioskState.serializer, stateJson());
  final KioskMenu currentMenu = parse(KioskMenu.serializer, menuJson());
  final calls = <String>[];
  final placed = <(String, List<KioskItemInput>, KioskOrderInputPaymentEnum)>[];
  AppFailure? placeFailure;
  KioskOrder Function(KioskOrderInputPaymentEnum payment)? onPlace;
  KioskOrder Function()? onRead;

  @override
  Future<KioskState> state() async => currentState;

  @override
  Future<KioskMenu> menu() async => currentMenu;

  @override
  Future<KioskOrder> place({
    required String key,
    required List<KioskItemInput> items,
    required KioskOrderInputPaymentEnum payment,
  }) async {
    placed.add((key, items, payment));
    final failure = placeFailure;
    if (failure != null) throw failure;
    return onPlace!(payment);
  }

  @override
  Future<KioskOrder> order(String id) async {
    calls.add('order');
    return onRead!();
  }

  @override
  Future<KioskOrder> finish(String id, String key) async {
    calls.add('finish');
    return kioskOrder(orderJson(status: 'paid', callNumber: 7));
  }

  @override
  Future<KioskOrder> payAtCounter(String id, String key) async {
    calls.add('pay_at_counter');
    return kioskOrder(orderJson(status: 'at_counter', callNumber: 8));
  }

  @override
  Future<KioskOrder> cancel(String id, String key) async {
    calls.add('cancel');
    return kioskOrder(orderJson(status: 'canceled'));
  }
}

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

void main() {
  late FakeKioskApi api;
  late KioskFlow flow;

  Future<void> open(WidgetTester tester) async {
    flow = KioskFlow(api: api);
    await tester.pumpWidget(localized(KioskView(flow: flow)));
    await flow.start();
    await tester.pump();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    flow.dispose();
  }

  Future<void> addCoffeeTwice(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('kiosk-start')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('kiosk-item-posmenuitem_1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('kiosk-item-posmenuitem_1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('kiosk-cart')));
    await tester.pump();
  }

  setUp(() => api = FakeKioskApi());

  testWidgets('waits paused until the kiosk opens, then welcomes the guest', (
    tester,
  ) async {
    api.currentState = parse(
      KioskState.serializer,
      stateJson(open: false, reason: 'shift_closed'),
    );
    await open(tester);
    expect(find.text('Kiosk đang tạm dừng'), findsOneWidget);
    expect(find.byKey(const Key('kiosk-start')), findsNothing);

    api.currentState = parse(KioskState.serializer, stateJson());
    await tester.pump(kioskStatePoll);
    await tester.pump();
    expect(find.byKey(const Key('kiosk-start')), findsOneWidget);
    await finish(tester);
  });

  testWidgets(
    'pays by QR, finishes on the bank confirmation and shows the call number',
    (tester) async {
      var received = false;
      api.onPlace = (_) => kioskOrder(
        orderJson(status: 'awaiting_payment', paymentState: 'waiting'),
      );
      api.onRead = () => kioskOrder(
        orderJson(
          status: 'awaiting_payment',
          paymentState: received ? 'received' : 'waiting',
        ),
      );
      await open(tester);
      await addCoffeeTwice(tester);

      expect(find.byKey(const Key('kiosk-line-0')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.byKey(const Key('kiosk-pay-qr')));
      await tester.pump();

      final (key, items, payment) = api.placed.single;
      expect(key, isNotEmpty);
      expect(payment, KioskOrderInputPaymentEnum.vietqr);
      expect(items.map((item) => (item.variantId, item.quantity)), [
        ('variant_1', 2),
      ]);
      expect(find.byKey(const Key('kiosk-qr-title')), findsOneWidget);
      expect(find.text('Quét mã để trả 60.000đ'), findsOneWidget);
      expect(find.text('Nội dung chuyển khoản: PV100'), findsOneWidget);

      await tester.pump(kioskPaymentPoll);
      await tester.pump();
      expect(api.calls, ['order']);
      received = true;
      await tester.pump(kioskPaymentPoll);
      await tester.pump();
      expect(api.calls, ['order', 'order', 'finish']);
      expect(find.byKey(const Key('kiosk-call-number')), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.textContaining('Đã nhận tiền'), findsOneWidget);

      await tester.tap(find.byKey(const Key('kiosk-next')));
      await tester.pump();
      expect(find.byKey(const Key('kiosk-start')), findsOneWidget);
      await finish(tester);
    },
  );

  testWidgets('leaves the order for the counter with its call number', (
    tester,
  ) async {
    api.onPlace = (_) =>
        kioskOrder(orderJson(status: 'at_counter', callNumber: 8));
    await open(tester);
    await addCoffeeTwice(tester);
    await tester.tap(find.byKey(const Key('kiosk-pay-counter')));
    await tester.pump();
    expect(api.placed.single.$3, KioskOrderInputPaymentEnum.counter);
    expect(find.text('8'), findsOneWidget);
    expect(find.textContaining('ra quầy thu ngân'), findsOneWidget);
    // Back to the start on its own for the next guest.
    await tester.pump(kioskDoneShown);
    await tester.pump();
    expect(find.byKey(const Key('kiosk-start')), findsOneWidget);
    await finish(tester);
  });

  testWidgets('hands an expired QR to the counter', (tester) async {
    api.onPlace = (_) => kioskOrder(
      orderJson(status: 'awaiting_payment', paymentState: 'waiting'),
    );
    api.onRead = () => kioskOrder(
      orderJson(status: 'awaiting_payment', paymentState: 'expired'),
    );
    await open(tester);
    await addCoffeeTwice(tester);
    await tester.tap(find.byKey(const Key('kiosk-pay-qr')));
    await tester.pump();
    await tester.pump(kioskPaymentPoll);
    await tester.pump();
    expect(api.calls, ['order', 'pay_at_counter']);
    expect(find.text('8'), findsOneWidget);
    await finish(tester);
  });

  testWidgets(
    'asks whether the guest is still there, then cancels the unpaid QR order',
    (tester) async {
      api.currentState = parse(KioskState.serializer, stateJson(idle: 15));
      api.onPlace = (_) => kioskOrder(
        orderJson(status: 'awaiting_payment', paymentState: 'waiting'),
      );
      api.onRead = () => kioskOrder(
        orderJson(status: 'awaiting_payment', paymentState: 'waiting'),
      );
      await open(tester);
      await addCoffeeTwice(tester);
      await tester.tap(find.byKey(const Key('kiosk-pay-qr')));
      await tester.pump();

      await tester.pump(const Duration(seconds: 15));
      await tester.pump();
      expect(find.byKey(const Key('kiosk-still-there')), findsOneWidget);
      expect(find.text('Đơn sẽ được hủy sau 10 giây.'), findsOneWidget);

      // A touch elsewhere does not answer it; the countdown runs out.
      for (var second = 0; second < 10; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();
      expect(api.calls, contains('cancel'));
      expect(find.byKey(const Key('kiosk-start')), findsOneWidget);
      await finish(tester);
    },
  );

  testWidgets('keeps the guest when they answer they are still there', (
    tester,
  ) async {
    api.currentState = parse(KioskState.serializer, stateJson(idle: 15));
    await open(tester);
    await tester.tap(find.byKey(const Key('kiosk-start')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 15));
    await tester.pump();
    await tester.tap(find.byKey(const Key('kiosk-still-here')));
    await tester.pump();
    expect(find.byKey(const Key('kiosk-still-there')), findsNothing);
    expect(find.byKey(const Key('kiosk-cart')), findsOneWidget);
    await finish(tester);
  });

  testWidgets('shows reconnecting and retries the order under the same key', (
    tester,
  ) async {
    api.placeFailure = const AppFailure.unreachable();
    api.onPlace = (_) =>
        kioskOrder(orderJson(status: 'at_counter', callNumber: 9));
    await open(tester);
    await addCoffeeTwice(tester);
    await tester.tap(find.byKey(const Key('kiosk-pay-counter')));
    await tester.pump();
    expect(find.byKey(const Key('kiosk-reconnecting')), findsOneWidget);

    api.placeFailure = null;
    await tester.tap(find.byKey(const Key('kiosk-pay-counter')));
    await tester.pump();
    expect(api.placed, hasLength(2));
    expect(api.placed[1].$1, api.placed[0].$1);
    expect(find.text('9'), findsOneWidget);
    expect(find.byKey(const Key('kiosk-reconnecting')), findsNothing);
    await finish(tester);
  });

  testWidgets('explains a sold out item and switches to English', (
    tester,
  ) async {
    api.placeFailure = const AppFailure.conflict(reason: 'item_sold_out');
    await open(tester);
    await tester.tap(find.byKey(const Key('kiosk-language')));
    await tester.pump();
    expect(find.text('Start ordering'), findsOneWidget);
    await addCoffeeTwice(tester);
    expect(find.text('Sold out'), findsNothing);
    await tester.tap(find.byKey(const Key('kiosk-pay-counter')));
    await tester.pump();
    expect(
      find.text('An item just sold out. Please remove it from your basket.'),
      findsOneWidget,
    );
    await finish(tester);
  });

  testWidgets('dims a sold out dish and keeps targets large', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('kiosk-start')));
    await tester.pump();
    expect(find.text('Hết món'), findsOneWidget);
    await tester.tap(find.byKey(const Key('kiosk-item-posmenuitem_2')));
    await tester.pump();
    expect(find.byKey(const Key('kiosk-cart')), findsOneWidget);
    expect(flow.cart.isEmpty, isTrue);
    expect(
      tester.getSize(find.byKey(const Key('kiosk-cart'))).height,
      greaterThanOrEqualTo(kioskTarget),
    );
    expect(
      tester.getSize(find.byKey(const Key('kiosk-low-reach'))).height,
      greaterThanOrEqualTo(kioskTarget),
    );
    await finish(tester);
  });

  testWidgets('warns the manager when the screen is not locked to the app', (
    tester,
  ) async {
    flow = KioskFlow(api: api);
    await tester.pumpWidget(localized(KioskView(flow: flow, locked: false)));
    await flow.start();
    await tester.pump();
    expect(find.byKey(const Key('kiosk-not-locked')), findsOneWidget);
    await tester.tap(find.byKey(const Key('kiosk-start')));
    await tester.pump();
    expect(find.byKey(const Key('kiosk-not-locked')), findsNothing);
    await finish(tester);
  });
}
