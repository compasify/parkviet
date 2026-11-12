import 'package:dio/dio.dart' show DioMediaType, MultipartFile;
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

  /// Sends a held course to the kitchen now.
  Future<Workspace> fireCourse(String workspaceId, int course);

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

  /// The POS modules turned on at the branch, from the device's context.
  Future<Set<String>> modules(String branchId);

  /// The open bar tabs of the branch, found by guest name, table or tab number.
  Future<List<WorkspaceSummary>> tabs(String branchId, {String? query});

  /// Opens a bar tab with only the guest's name; the phone holds its lease.
  Future<Workspace> openTab(String branchId, String name, {required String editorId});

  /// The branch's kept bottles matching a code, phone or guest name.
  Future<List<BottleKeep>> bottles(String branchId, String query);

  /// Pours from a kept bottle for free: its new level, the ml poured and a
  /// photo (JPEG bytes) of the bottle.
  Future<BottleKeep> pour(String id, {required int levelPercent, int? ml, String? workspaceId, List<int>? photo});

  /// What the person signed in may do at the branch, from the device's context.
  Future<Set<String>> capabilities(String branchId);

  /// Starts a room's clock on the server's time. A room without an open
  /// order gets one, its lease held by [editorId]; a room with several
  /// names the order to bill ([workspaceId]).
  Future<TimedSessionCommand> startClock(String branchId, String resourceId,
      {required String editorId, String? workspaceId});

  /// Stops a clock now on the server's time; its line is billed.
  Future<TimedSessionCommand> stopClock(String sessionId);

  /// Moves a running clock and the room's order to a free room.
  Future<TimedSessionCommand> moveClock(String sessionId, String resourceId);
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
  Future<Workspace> fireCourse(String workspaceId, int course) async => (await client.call((api) => api.posCourseFire(
            idempotencyKey: _key,
            workspaceId: workspaceId,
            course: course,
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

  @override
  Future<Set<String>> modules(String branchId) async {
    final context = await client.call((api) => api.posContext(branchId: branchId));
    return {...?context.modules?.entries.where((entry) => entry.value).map((entry) => entry.key)};
  }

  @override
  Future<List<WorkspaceSummary>> tabs(String branchId, {String? query}) async => (await client.call((api) =>
          api.posWorkspaceList(
            branchId: branchId,
            serviceMode: 'tab',
            status: 'editing,parked',
            q: query == null || query.trim().isEmpty ? null : query.trim(),
            limit: 100,
          )))
      .data
      .toList();

  @override
  Future<Workspace> openTab(String branchId, String name, {required String editorId}) async =>
      (await client.call((api) => api.posWorkspaceCreate(
                idempotencyKey: _key,
                workspaceCreateInput: WorkspaceCreateInput((b) => b
                  ..branchId = branchId
                  ..editorId = editorId
                  ..serviceMode = WorkspaceCreateInputServiceModeEnum.tab
                  ..tabName = name.trim()),
              )))
          .data;

  @override
  Future<List<BottleKeep>> bottles(String branchId, String query) async =>
      (await client.call((api) => api.posBottleKeepList(branchId: branchId, q: query.trim()))).data.toList();

  @override
  Future<BottleKeep> pour(String id, {required int levelPercent, int? ml, String? workspaceId, List<int>? photo}) async =>
      (await client.call((api) => api.posBottleKeepPour(
                idempotencyKey: _key,
                id: id,
                levelPercent: levelPercent,
                ml: ml,
                workspaceId: workspaceId,
                photo: photo == null
                    ? null
                    : MultipartFile.fromBytes(photo, filename: 'bottle.jpg', contentType: DioMediaType('image', 'jpeg')),
              )))
          .data;

  @override
  Future<Set<String>> capabilities(String branchId) async {
    final context = await client.call((api) => api.posContext(branchId: branchId));
    return {...context.capabilities};
  }

  @override
  Future<TimedSessionCommand> startClock(String branchId, String resourceId,
          {required String editorId, String? workspaceId}) async =>
      (await client.call((api) => api.posTimedSessionStart(
                idempotencyKey: _key,
                resourceId: resourceId,
                timedSessionStartInput: TimedSessionStartInput((b) => b
                  ..branchId = branchId
                  ..editorId = editorId
                  ..workspaceId = workspaceId),
              )))
          .data;

  @override
  Future<TimedSessionCommand> stopClock(String sessionId) async =>
      (await client.call((api) => api.posTimedSessionStop(idempotencyKey: _key, id: sessionId))).data;

  @override
  Future<TimedSessionCommand> moveClock(String sessionId, String resourceId) async =>
      (await client.call((api) => api.posTimedSessionMove(
                idempotencyKey: _key,
                id: sessionId,
                timedSessionMoveInput: TimedSessionMoveInput((b) => b..resourceId = resourceId),
              )))
          .data;
}
