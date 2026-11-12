import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/approval_requests.dart';
import 'package:parkviet_staff/core/errors.dart';
import 'package:parkviet_staff/modes/owner/owner_device.dart';
import 'package:parkviet_staff/modes/owner/owner_home.dart';
import 'package:parkviet_staff/modes/owner/owner_screen.dart';
import 'package:parkviet_staff/modes/owner/owner_watch_api.dart';
import 'package:parkviet_staff/modes/waiter/table_order_screen.dart';
import 'package:parkviet_staff/modes/waiter/waiter_context.dart';
import 'package:pos_api/pos_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../waiter/waiter_fixtures.dart';

Map<String, Object?> requestJson(
  String id, {
  String status = 'pending',
  String? reason,
  String? amount,
}) => {
  'id': id,
  'branch_id': 'posbranch_1',
  'branch_name': 'Quận 1',
  'requester_id': 'staff_2',
  'requester_name': 'Lan',
  'action': 'kitchen.void_sent',
  'subject_type': 'workspace',
  'subject_id': 'posws_1',
  'subject_label': 'Bàn 5',
  'revision': '3',
  'amount': amount,
  'currency': amount == null ? null : 'VND',
  'reason': reason,
  'status': status,
  'approval_id': status == 'granted' ? 'posappr_9' : null,
  'decided_by_name': null,
  'decided_at': null,
  'expires_at': '2026-11-12T10:10:00Z',
  'created_at': '2026-11-12T10:00:00Z',
};

ApprovalRequest request(
  String id, {
  String status = 'pending',
  String? reason,
  String? amount,
}) => parse(
  ApprovalRequest.serializer,
  requestJson(id, status: status, reason: reason, amount: amount),
);

class FakeApprovals implements ApprovalRequestsApi {
  final calls = <String>[];
  List<ApprovalRequest> waiting = [];
  ApprovalRequest? answer;
  AppFailure? failure;

  @override
  Future<ApprovalRequest> ask({
    required String branchId,
    required String workspaceId,
    required String action,
    required int revision,
    String? amount,
    String? reason,
  }) async {
    calls.add('ask:$workspaceId:$action:$revision:$reason');
    return request('posapprovalreq_1');
  }

  @override
  Future<ApprovalRequest> show(String id) async => answer ?? request(id);

  @override
  Future<ApprovalRequest> cancel(String id) async {
    calls.add('cancel:$id');
    return request(id, status: 'canceled');
  }

  @override
  Future<List<ApprovalRequest>> pending(String branchId) async {
    calls.add('pending:$branchId');
    return waiting;
  }

  @override
  Future<ApprovalRequest> grant(String id) async {
    calls.add('grant:$id');
    if (failure case final error?) throw error;
    waiting = [];
    return request(id, status: 'granted');
  }

  @override
  Future<ApprovalRequest> decline(String id, {String? reason}) async {
    calls.add('decline:$id:$reason');
    waiting = [];
    return request(id, status: 'declined', reason: reason);
  }
}

class FakeWatch implements OwnerWatchApi {
  final calls = <String>[];
  bool reports = true;

  @override
  Future<List<OwnerBranch>> branches() async => [
    for (final (id, name) in [
      ('posbranch_1', 'Quận 1'),
      ('posbranch_2', 'Quận 3'),
    ])
      parse(OwnerBranch.serializer, {
        'id': id,
        'name': name,
        'code': id,
        'timezone': 'Asia/Ho_Chi_Minh',
        'can_read_reports': reports,
        'can_approve': true,
      }),
  ];

  @override
  Future<OwnerToday> today(String branchId) async {
    calls.add('today:$branchId');
    return parse(OwnerToday.serializer, {
      'branch_id': branchId,
      'business_date': '2026-11-12',
      'timezone': 'Asia/Ho_Chi_Minh',
      'currency': 'VND',
      'orders': 2,
      'sales_total': '150000.0',
      'returns_total': '0.0',
      'net_sales': '150000.0',
      'by_source': [
        {
          'order_source': 'counter',
          'orders': 2,
          'sales_total': '150000.0',
          'owed': '0.0',
        },
      ],
      'by_hour': [
        {'hour': 11, 'orders': 1, 'sales_total': '120000.0'},
        {'hour': 12, 'orders': 1, 'sales_total': '30000.0'},
      ],
      'open_units': 1,
      'open_orders': 1,
      'open_total': '45000.0',
      'open_shifts': 1,
      'canceled_orders': 0,
      'voided_items': 0,
      'pending_approvals': 1,
    });
  }

  @override
  Future<List<OwnerOpenUnit>> openUnits(String branchId) async => [
    parse(OwnerOpenUnit.serializer, {
      'workspace_id': 'posws_1',
      'resource_id': 'posres_1',
      'label': 'Bàn 5',
      'service_mode': 'table',
      'status': 'editing',
      'guest_count': 2,
      'opened_at': '2026-11-12T10:00:00Z',
      'minutes_open': 42,
      'total': '45000.0',
      'kitchen_waiting': 2,
      'kitchen_late': true,
    }),
  ];

  @override
  Future<List<OwnerAlert>> alerts(String branchId) async {
    calls.add('alerts:$branchId');
    return [
      parse(OwnerAlert.serializer, {
        'id': 'posowneralert_1',
        'branch_id': branchId,
        'kind': 'shift_variance',
        'subject_id': 'posshift_1',
        'details': {'variance': '-10000.0', 'currency': 'VND'},
        'occurred_at': '2026-11-12T10:00:00Z',
      }),
    ];
  }

  @override
  Future<PushRegistrationState> push() async => parse(
    PushRegistrationState.serializer,
    {'registration': null, 'relay': false},
  );

  @override
  Future<PushRegistrationState> updatePush({
    String? platform,
    String? token,
    bool? enabled,
  }) async {
    calls.add('push:$platform:$enabled');
    return push();
  }
}

class FakeBookings implements OwnerApi {
  @override
  Future<List<Reservation>> reservations(String branchId) async => [];

  @override
  Future<Reservation> refundDeposit(String depositId) =>
      throw UnimplementedError();

  @override
  Future<Reservation> forfeitDeposit(String depositId) =>
      throw UnimplementedError();
}

class FakeConfirmation implements ApproverConfirmation {
  FakeConfirmation(this.answer);

  ApproverCheck answer;
  int asked = 0;

  @override
  Future<ApproverCheck> confirm(String reason) async {
    asked++;
    return answer;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<
    ({
      FakeApprovals approvals,
      FakeWatch watch,
      StreamController<Map<String, Object?>> events,
      List<String> opened,
    })
  >
  pumpHome(
    WidgetTester tester, {
    ApproverCheck check = ApproverCheck.passed,
    OwnerTab tab = OwnerTab.approvals,
  }) async {
    final approvals = FakeApprovals()
      ..waiting = [request('posapprovalreq_1', reason: 'Khách đổi ý')];
    final watch = FakeWatch();
    final events = eventSource();
    addTearDown(events.close);
    final opened = <String>[];
    await tester.pumpWidget(
      localized(
        Scaffold(
          body: OwnerHome(
            watch: watch,
            approvals: approvals,
            reservations: FakeBookings(),
            confirmation: FakeConfirmation(check),
            pushTokens: const NoPushTokenSource(),
            initialTab: tab,
            eventsFor: (branchId) {
              opened.add(branchId);
              return BranchEvents(events.stream);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (approvals: approvals, watch: watch, events: events, opened: opened);
  }

  testWidgets(
    'grants a waiting approval after the fingerprint, and hears new ones on the branch',
    (tester) async {
      final home = await pumpHome(tester);
      expect(find.text('Hủy món đã gửi bếp'), findsOneWidget);
      expect(find.textContaining('Bàn 5 · Lan xin duyệt'), findsOneWidget);
      expect(find.text('Lý do: Khách đổi ý'), findsOneWidget);

      await tester.tap(find.byKey(const Key('owner-grant-posapprovalreq_1')));
      await tester.pumpAndSettle();
      expect(home.approvals.calls, contains('grant:posapprovalreq_1'));
      expect(find.text('Đã duyệt; máy gửi sẽ tự tiếp tục.'), findsOneWidget);
      expect(find.text('Không có yêu cầu nào đang chờ.'), findsOneWidget);

      home.approvals.waiting = [request('posapprovalreq_2', amount: '20000')];
      home.events.add({
        'event': 'approval_request.created',
        'id': 'posapprovalreq_2',
        'refs': {'workspace_id': 'posws_1'},
      });
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('owner-request-posapprovalreq_2')),
        findsOneWidget,
      );
      expect(find.text('20.000đ'), findsOneWidget);
    },
  );

  testWidgets(
    'does not grant when the fingerprint fails, and asks plainly on a phone without one',
    (tester) async {
      final home = await pumpHome(tester, check: ApproverCheck.failed);
      await tester.tap(find.byKey(const Key('owner-grant-posapprovalreq_1')));
      await tester.pumpAndSettle();
      expect(
        home.approvals.calls.where((call) => call.startsWith('grant')),
        isEmpty,
      );
      expect(
        find.text('Chưa xác nhận được vân tay hoặc khuôn mặt.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'falls back to a confirmation without biometrics and explains a refused self-approval',
    (tester) async {
      final home = await pumpHome(tester, check: ApproverCheck.unavailable);
      home.approvals.failure = const AppFailure.conflict(
        reason: 'approver_is_requester',
      );
      await tester.tap(find.byKey(const Key('owner-grant-posapprovalreq_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('owner-grant-confirm')));
      await tester.pumpAndSettle();
      expect(home.approvals.calls, contains('grant:posapprovalreq_1'));
      expect(
        find.text('Bạn không thể tự duyệt yêu cầu của mình.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('declines with a reason', (tester) async {
    final home = await pumpHome(tester);
    await tester.tap(find.byKey(const Key('owner-decline-posapprovalreq_1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('owner-decline-reason')),
      'Không đúng quy định',
    );
    await tester.tap(find.byKey(const Key('owner-decline-confirm')));
    await tester.pumpAndSettle();
    expect(
      home.approvals.calls,
      contains('decline:posapprovalreq_1:Không đúng quy định'),
    );
    expect(find.text('Đã từ chối.'), findsOneWidget);
  });

  testWidgets(
    'shows the day, the open orders and the alerts, and switches branch with its own events',
    (tester) async {
      final home = await pumpHome(tester, tab: OwnerTab.today);
      expect(find.byKey(const Key('owner-today-sales')), findsOneWidget);
      // Sales, net sales and the counter source.
      expect(find.text('150.000đ'), findsNWidgets(3));
      expect(find.byKey(const Key('owner-hour-11')), findsOneWidget);
      expect(home.opened, ['posbranch_1']);

      await tester.tap(find.byKey(const Key('owner-tab-open')));
      await tester.pumpAndSettle();
      expect(find.text('42 phút'), findsOneWidget);
      expect(find.text('2 món trễ bếp'), findsOneWidget);

      await tester.tap(find.byKey(const Key('owner-tab-alerts')));
      await tester.pumpAndSettle();
      expect(find.text('Chênh lệch két khi đóng ca: -10.000đ'), findsOneWidget);

      home.events.add({
        'event': 'owner_alert.created',
        'id': 'posowneralert_2',
      });
      await tester.pumpAndSettle();
      expect(
        home.watch.calls.where((call) => call == 'alerts:posbranch_1'),
        hasLength(2),
      );

      await tester.tap(find.byKey(const Key('owner-branch')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quận 3').last);
      await tester.pumpAndSettle();
      expect(home.opened, ['posbranch_1', 'posbranch_2']);
      expect(home.watch.calls, contains('today:posbranch_2'));
      expect(
        (await SharedPreferences.getInstance()).getString('owner.branch_id'),
        'posbranch_2',
      );
    },
  );

  testWidgets('says push is not set up on a build without a push token', (
    tester,
  ) async {
    await pumpHome(tester, tab: OwnerTab.today);
    await tester.tap(find.byKey(const Key('owner-push')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('chỉ nhận sự kiện khi app đang mở'),
      findsOneWidget,
    );
    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('owner-push-toggle')),
    );
    expect(toggle.onChanged, isNull);
  });

  group('asking the owner from the void dialog', () {
    Future<
      (FakeWaiterApi, FakeApprovals, StreamController<Map<String, Object?>>)
    >
    openVoid(WidgetTester tester) async {
      final events = eventSource();
      addTearDown(events.close);
      final api = FakeWaiterApi(
        workspace: workspace(
          lines: [lineJson('l1', sent: '2', pending: '0')],
        ),
      );
      final approvals = FakeApprovals();
      final waiter = WaiterContext(
        api: api,
        branchId: 'posbranch_1',
        deviceId: 'posdev_1',
        editorId: 'editor-1',
        baseUrl: 'http://pos.test',
        events: events.stream,
        approvals: approvals,
      );
      addTearDown(waiter.dispose);
      await tester.pumpWidget(
        localized(TableOrderScreen(waiter: waiter, workspaceId: 'posws_1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('line-l1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('line-void-l1')));
      await tester.pumpAndSettle();
      api.failures.add(
        const AppFailure.conflict(
          reason: 'approval_required',
          currentRevision: 3,
        ),
      );
      await tester.tap(find.byKey(const Key('void-confirm')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('void-ask-owner')));
      await tester.tap(find.byKey(const Key('void-ask-owner')));
      await tester.pumpAndSettle();
      return (api, approvals, events);
    }

    testWidgets(
      'sends the request and carries on by itself once the owner grants it',
      (tester) async {
        final (api, approvals, events) = await openVoid(tester);
        expect(
          approvals.calls.single,
          startsWith('ask:posws_1:kitchen.void_sent:3:'),
        );
        expect(find.byKey(const Key('void-asked-owner')), findsOneWidget);

        events.add({
          'event': 'approval.requested',
          'id': 'posappr_9',
          'refs': {'workspace_id': 'posws_1'},
        });
        await tester.pumpAndSettle();
        expect(api.calls.last, 'void:possline_l1:1:khach_doi_y:posappr_9');
        expect(find.text('Đã hủy món.'), findsOneWidget);
        expect(
          approvals.calls.where((call) => call.startsWith('cancel')),
          isEmpty,
        );
      },
    );

    testWidgets(
      'tells the refusal and withdraws a request left waiting when closed',
      (tester) async {
        final (_, approvals, events) = await openVoid(tester);
        approvals.answer = request(
          'posapprovalreq_1',
          status: 'declined',
          reason: 'Không được',
        );
        events.add({
          'event': 'approval_request.updated',
          'id': 'posapprovalreq_1',
        });
        await tester.pumpAndSettle();
        expect(find.text('Chủ quán đã từ chối: Không được'), findsOneWidget);
        expect(find.byKey(const Key('void-ask-owner')), findsOneWidget);

        approvals.answer = null;
        await tester.ensureVisible(find.byKey(const Key('void-ask-owner')));
        await tester.tap(find.byKey(const Key('void-ask-owner')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hủy'));
        await tester.pumpAndSettle();
        expect(approvals.calls.last, 'cancel:posapprovalreq_1');
      },
    );
  });
}
