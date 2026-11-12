import 'package:pos_api/pos_api.dart';

import '../../core/api_client.dart';

/// One dish in the guest's basket, as the kiosk sends it. The server prices
/// it again from its own menu; nothing here sets a price.
class KioskItemInput {
  const KioskItemInput({
    required this.variantId,
    required this.quantity,
    this.options = const [],
    this.note,
  });

  final String variantId;
  final int quantity;

  /// Option ids and how many of each.
  final List<(String, int)> options;
  final String? note;
}

/// The self-ordering kiosk's side of the server, as the device itself (no
/// staff session). Writes carry the Idempotency-Key the caller chose, so a
/// retry after a lost answer replays the same order instead of placing two.
abstract interface class KioskApi {
  Future<KioskState> state();

  Future<KioskMenu> menu();

  Future<KioskOrder> place({
    required String key,
    required List<KioskItemInput> items,
    required KioskOrderInputPaymentEnum payment,
  });

  Future<KioskOrder> order(String id);

  Future<KioskOrder> finish(String id, String key);

  Future<KioskOrder> payAtCounter(String id, String key);

  Future<KioskOrder> cancel(String id, String key);
}

/// [KioskApi] over the generated client.
class ApiKioskApi implements KioskApi {
  ApiKioskApi(this.client);

  final PosApiClient client;

  @override
  Future<KioskState> state() async =>
      (await client.call((api) => api.posKioskState())).data;

  @override
  Future<KioskMenu> menu() async =>
      (await client.call((api) => api.posKioskMenu())).data;

  @override
  Future<KioskOrder> place({
    required String key,
    required List<KioskItemInput> items,
    required KioskOrderInputPaymentEnum payment,
  }) async => (await client.call(
    (api) => api.posKioskPlaceOrder(
      idempotencyKey: key,
      kioskOrderInput: KioskOrderInput(
        (b) => b
          ..payment = payment
          ..items.replace([
            for (final item in items)
              KioskOrderItemInput(
                (row) => row
                  ..variantId = item.variantId
                  ..quantity = item.quantity
                  ..note = item.note
                  ..modifiers.replace([
                    for (final (id, quantity) in item.options)
                      ModifierSelection(
                        (option) => option
                          ..optionId = id
                          ..quantity = quantity,
                      ),
                  ]),
              ),
          ]),
      ),
    ),
  )).data;

  @override
  Future<KioskOrder> order(String id) async =>
      (await client.call((api) => api.posKioskOrder(id: id))).data;

  @override
  Future<KioskOrder> finish(String id, String key) async => (await client.call(
    (api) => api.posKioskFinishOrder(idempotencyKey: key, id: id),
  )).data;

  @override
  Future<KioskOrder> payAtCounter(String id, String key) async =>
      (await client.call(
        (api) => api.posKioskPayAtCounter(idempotencyKey: key, id: id),
      )).data;

  @override
  Future<KioskOrder> cancel(String id, String key) async => (await client.call(
    (api) => api.posKioskCancelOrder(idempotencyKey: key, id: id),
  )).data;
}
