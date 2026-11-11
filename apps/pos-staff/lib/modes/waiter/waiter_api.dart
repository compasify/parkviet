import 'package:pos_api/pos_api.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';

/// What the waiter's phone asks of the server, as the person signed in
/// with their PIN. Every command goes through the same table endpoints as
/// the counter. Nothing here takes money.
abstract interface class WaiterApi {
  Future<ResourceBoard> tables(String branchId);

  Future<Menu> menu(String branchId);

  Future<Workspace> workspace(String id);

  /// Opens a free table, or a second order on a busy one ([addOrder]).
  /// The phone ([editorId]) holds the order's editing lease afterwards.
  Future<Workspace> open(String branchId, String resourceId, {required String editorId, int? guestCount, bool addOrder});

  Future<Workspace> append(String workspaceId, List<AppendItem> items, {required String batchId});

  Future<Workspace> sendToKitchen(String workspaceId);

  /// Voids [quantity] of a line the kitchen has, for a reason; spends an
  /// approval when the person may not void.
  Future<Workspace> voidSent(
    String workspaceId,
    String saleLineId, {
    required int quantity,
    required String reasonCode,
    String? note,
    String? approvalId,
  });

  /// Takes a line nobody sent to the kitchen yet off the order.
  Future<Workspace> removeUnsent(String workspaceId, WorkspaceLine line);

  Future<Workspace> requestPayment(String workspaceId);

  Future<PrebillOutcome> prebill(String workspaceId, {String? printerId});

  /// The checklist of the table: queued on [printerId], or only answered
  /// for the phone to print itself.
  Future<ChecklistOutcome> checklist(String workspaceId, {String? printerId});

  Future<Workspace> claimLease(String workspaceId, String editorId);

  Future<Workspace> move(Workspace workspace, {required String editorId, required String resourceId});

  Future<Workspace> merge(Workspace workspace, {required String editorId, required String targetWorkspaceId});

  /// Dishes ready or served in the last 30 minutes on this phone's tables;
  /// with [areaId], on every table of that area.
  Future<ReadyFeed> readyFeed({String? areaId});

  Future<TablePins> pins();

  Future<TablePins> pin(String resourceId, {required bool pinned});

  Future<List<Printer>> printers(String branchId);

  /// The branch's reasons for voiding a sent dish, from the device's
  /// context; null when the server does not list them.
  Future<List<String>?> voidReasons(String branchId);
}

/// [WaiterApi] over the generated client.
class ApiWaiterApi implements WaiterApi {
  ApiWaiterApi(this.client, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final PosApiClient client;
  final Uuid _uuid;

  String get _key => _uuid.v4();

  @override
  Future<ResourceBoard> tables(String branchId) async =>
      (await client.call((api) => api.posResourceBoard(branchId: branchId))).data;

  @override
  Future<Menu> menu(String branchId) async => (await client.call((api) => api.posMenu(branchId: branchId))).data;

  @override
  Future<Workspace> workspace(String id) async => (await client.call((api) => api.posWorkspaceShow(id: id))).data;

  @override
  Future<Workspace> open(String branchId, String resourceId,
          {required String editorId, int? guestCount, bool addOrder = false}) async =>
      (await client.call((api) => api.posTableOpen(
                idempotencyKey: _key,
                resourceId: resourceId,
                tableOpenInput: TableOpenInput((b) => b
                  ..branchId = branchId
                  ..editorId = editorId
                  ..guestCount = guestCount
                  ..addOrder = addOrder),
              )))
          .data;

  @override
  Future<Workspace> append(String workspaceId, List<AppendItem> items, {required String batchId}) async =>
      (await client.call((api) => api.posWorkspaceAppendItems(
                idempotencyKey: _key,
                workspaceId: workspaceId,
                appendItemsInput: AppendItemsInput((b) => b
                  ..items.replace(items)
                  ..appendBatchId = batchId),
              )))
          .data;

  @override
  Future<Workspace> sendToKitchen(String workspaceId) async => (await client.call((api) => api.posKitchenSend(
            idempotencyKey: _key,
            workspaceId: workspaceId,
            kitchenSendInput: KitchenSendInput(),
          )))
      .data;

  @override
  Future<Workspace> voidSent(
    String workspaceId,
    String saleLineId, {
    required int quantity,
    required String reasonCode,
    String? note,
    String? approvalId,
  }) async =>
      (await client.call((api) => api.posKitchenVoid(
                idempotencyKey: _key,
                workspaceId: workspaceId,
                saleLineId: saleLineId,
                kitchenVoidInput: KitchenVoidInput((b) => b
                  ..quantity = quantity
                  ..reasonCode = reasonCode
                  ..note = note
                  ..approvalId = approvalId),
              )))
          .data;

  @override
  Future<Workspace> removeUnsent(String workspaceId, WorkspaceLine line) async =>
      (await client.call((api) => api.posWorkspaceRemoveUnsentLine(
                idempotencyKey: _key,
                workspaceId: workspaceId,
                id: line.id,
                rowVersion: line.rowVersion ?? 0,
              )))
          .data;

  @override
  Future<Workspace> requestPayment(String workspaceId) async => (await client.call((api) => api.posPaymentRequest(
            idempotencyKey: _key,
            workspaceId: workspaceId,
            paymentRequestInput: PaymentRequestInput(),
          )))
      .data;

  @override
  Future<PrebillOutcome> prebill(String workspaceId, {String? printerId}) async =>
      (await client.call((api) => api.posPrebill(
                idempotencyKey: _key,
                workspaceId: workspaceId,
                prebillInput: PrebillInput((b) => b..printerId = printerId),
              )))
          .data;

  @override
  Future<ChecklistOutcome> checklist(String workspaceId, {String? printerId}) async =>
      (await client.call((api) => api.posWorkspaceChecklist(
                idempotencyKey: _key,
                workspaceId: workspaceId,
                checklistInput: ChecklistInput((b) => b..printerId = printerId),
              )))
          .data;

  @override
  Future<Workspace> claimLease(String workspaceId, String editorId) async =>
      (await client.call((api) => api.posWorkspaceClaimLease(
                id: workspaceId,
                idempotencyKey: _key,
                leaseClaimInput: LeaseClaimInput((b) => b..editorId = editorId),
              )))
          .data;

  @override
  Future<Workspace> move(Workspace workspace, {required String editorId, required String resourceId}) async {
    final leased = await claimLease(workspace.id, editorId);
    return (await client.call((api) => api.posTableMove(
              idempotencyKey: _key,
              workspaceId: workspace.id,
              tableMoveInput: TableMoveInput((b) => b
                ..expectedRevision = leased.revision
                ..leaseGeneration = leased.leaseGeneration ?? 0
                ..editorId = editorId
                ..resourceId = resourceId),
            )))
        .data;
  }

  @override
  Future<Workspace> merge(Workspace workspace, {required String editorId, required String targetWorkspaceId}) async {
    final leased = await claimLease(workspace.id, editorId);
    return (await client.call((api) => api.posTableMerge(
              idempotencyKey: _key,
              workspaceId: workspace.id,
              tableMergeInput: TableMergeInput((b) => b
                ..expectedRevision = leased.revision
                ..leaseGeneration = leased.leaseGeneration ?? 0
                ..editorId = editorId
                ..targetWorkspaceId = targetWorkspaceId),
            )))
        .data;
  }

  @override
  Future<ReadyFeed> readyFeed({String? areaId}) async =>
      (await client.call((api) => api.posDeviceReadyFeed(areaId: areaId))).data;

  @override
  Future<TablePins> pins() async => (await client.call((api) => api.posDeviceTablePins())).data;

  @override
  Future<TablePins> pin(String resourceId, {required bool pinned}) async => (await client.call((api) => pinned
          ? api.posDeviceTablePin(
              idempotencyKey: _key,
              tablePinInput: TablePinInput((b) => b..resourceId = resourceId),
            )
          : api.posDeviceTableUnpin(idempotencyKey: _key, resourceId: resourceId)))
      .data;

  @override
  Future<List<Printer>> printers(String branchId) async =>
      (await client.call((api) => api.posPrinters(branchId: branchId))).data.toList();

  @override
  Future<List<String>?> voidReasons(String branchId) async {
    final context = await client.call((api) => api.posContext(branchId: branchId));
    return context.branches?.where((branch) => branch.id == branchId).firstOrNull?.voidReasons?.toList();
  }
}
