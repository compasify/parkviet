import 'package:pos_api/pos_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api_client.dart';

/// Guests' orders and requests from the table QR, as the person signed in
/// with their PIN reads and decides them. Accepting adds the items to the
/// table's order and sends them to the kitchen on the server.
abstract interface class GuestOrdersApi {
  /// Orders waiting for staff, oldest first; with [areaId], of that area.
  Future<List<GuestOrder>> pending(String branchId, {String? areaId});

  /// Calls for staff and for the bill still open.
  Future<List<GuestRequest>> requests(String branchId, {String? areaId});

  Future<GuestOrder> accept(String id);

  Future<GuestOrder> reject(String id, String reason);

  Future<GuestRequest> done(String id);
}

/// [GuestOrdersApi] over the generated client.
class ApiGuestOrdersApi implements GuestOrdersApi {
  ApiGuestOrdersApi(this.client, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final PosApiClient client;
  final Uuid _uuid;

  String get _key => _uuid.v4();

  @override
  Future<List<GuestOrder>> pending(String branchId, {String? areaId}) async =>
      (await client.call(
        (api) => api.posGuestOrderList(
          branchId: branchId,
          status: 'pending',
          areaId: areaId,
        ),
      )).data.toList();

  @override
  Future<List<GuestRequest>> requests(
    String branchId, {
    String? areaId,
  }) async => (await client.call(
    (api) => api.posGuestRequestList(branchId: branchId, areaId: areaId),
  )).data.toList();

  @override
  Future<GuestOrder> accept(String id) async => (await client.call(
    (api) => api.posGuestOrderAccept(idempotencyKey: _key, id: id),
  )).data;

  @override
  Future<GuestOrder> reject(String id, String reason) async =>
      (await client.call(
        (api) => api.posGuestOrderReject(
          idempotencyKey: _key,
          id: id,
          guestOrderRejectInput: GuestOrderRejectInput(
            (b) => b..reason = reason,
          ),
        ),
      )).data;

  @override
  Future<GuestRequest> done(String id) async => (await client.call(
    (api) => api.posGuestRequestDone(idempotencyKey: _key, id: id),
  )).data;
}
