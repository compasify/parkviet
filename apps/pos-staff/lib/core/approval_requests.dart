import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';
import 'package:uuid/uuid.dart';

import 'api_client.dart';
import 'session.dart';

/// Asking a manager on another device for an approval, and answering one.
/// Granting issues an ordinary approval bound to the order as it was when
/// asked; the asking device then spends it like a code typed in.
abstract interface class ApprovalRequestsApi {
  /// Asks for `action` on an order at `revision`.
  Future<ApprovalRequest> ask({
    required String branchId,
    required String workspaceId,
    required String action,
    required int revision,
    String? amount,
    String? reason,
  });

  Future<ApprovalRequest> show(String id);

  Future<ApprovalRequest> cancel(String id);

  /// The pending requests the person may decide, of one branch.
  Future<List<ApprovalRequest>> pending(String branchId);

  Future<ApprovalRequest> grant(String id);

  Future<ApprovalRequest> decline(String id, {String? reason});
}

class ApiApprovalRequestsApi implements ApprovalRequestsApi {
  ApiApprovalRequestsApi(this.client, {Uuid uuid = const Uuid()})
    : _uuid = uuid;

  final PosApiClient client;
  final Uuid _uuid;

  @override
  Future<ApprovalRequest> ask({
    required String branchId,
    required String workspaceId,
    required String action,
    required int revision,
    String? amount,
    String? reason,
  }) async => (await client.call(
    (api) => api.posApprovalRequestCreate(
      idempotencyKey: _key(),
      approvalRequestInput: ApprovalRequestInput(
        (b) => b
          ..branchId = branchId
          ..workspaceId = workspaceId
          ..actionName = action
          ..revision = '$revision'
          ..amount = amount
          ..reason = reason,
      ),
    ),
  )).data;

  @override
  Future<ApprovalRequest> show(String id) async =>
      (await client.call((api) => api.posApprovalRequestShow(id: id))).data;

  @override
  Future<ApprovalRequest> cancel(String id) async => (await client.call(
    (api) => api.posApprovalRequestCancel(idempotencyKey: _key(), id: id),
  )).data;

  @override
  Future<List<ApprovalRequest>> pending(String branchId) async =>
      (await client.call(
        (api) => api.posApprovalRequestList(
          branchId: branchId,
          status: 'pending',
          limit: 100,
        ),
      )).data.toList();

  @override
  Future<ApprovalRequest> grant(String id) async => (await client.call(
    (api) => api.posApprovalRequestGrant(idempotencyKey: _key(), id: id),
  )).data;

  @override
  Future<ApprovalRequest> decline(String id, {String? reason}) async =>
      (await client.call(
        (api) => api.posApprovalRequestDecline(
          idempotencyKey: _key(),
          id: id,
          approvalRequestDeclineInput: ApprovalRequestDeclineInput(
            (b) => b..reason = reason,
          ),
        ),
      )).data;

  // A new key per tap: the server answers a decided request as it stands.
  String _key() => _uuid.v4();
}

final approvalRequestsApiProvider = Provider<ApprovalRequestsApi>(
  (ref) => ApiApprovalRequestsApi(ref.watch(apiClientProvider)),
);
