import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_api/pos_api.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/session.dart';

/// What the owner's phone reads of the branches the person watches: the
/// day so far, the open orders, the alerts, and this phone's push
/// registration.
abstract interface class OwnerWatchApi {
  Future<List<OwnerBranch>> branches();

  Future<OwnerToday> today(String branchId);

  Future<List<OwnerOpenUnit>> openUnits(String branchId);

  Future<List<OwnerAlert>> alerts(String branchId);

  Future<PushRegistrationState> push();

  /// Stores this phone's push token, or turns push on or off.
  Future<PushRegistrationState> updatePush({
    String? platform,
    String? token,
    bool? enabled,
  });
}

class ApiOwnerWatchApi implements OwnerWatchApi {
  ApiOwnerWatchApi(this.client, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final PosApiClient client;
  final Uuid _uuid;

  @override
  Future<List<OwnerBranch>> branches() async =>
      (await client.call((api) => api.posOwnerBranches())).data.toList();

  @override
  Future<OwnerToday> today(String branchId) async =>
      (await client.call((api) => api.posOwnerToday(branchId: branchId))).data;

  @override
  Future<List<OwnerOpenUnit>> openUnits(String branchId) async =>
      (await client.call(
        (api) => api.posOwnerOpenUnits(branchId: branchId),
      )).data.toList();

  @override
  Future<List<OwnerAlert>> alerts(String branchId) async => (await client.call(
    (api) => api.posOwnerAlerts(branchId: branchId),
  )).data.toList();

  @override
  Future<PushRegistrationState> push() async =>
      (await client.call((api) => api.posPushRegistrationShow())).data;

  @override
  Future<PushRegistrationState> updatePush({
    String? platform,
    String? token,
    bool? enabled,
  }) async => (await client.call(
    (api) => api.posPushRegistrationUpdate(
      idempotencyKey: _uuid.v4(),
      pushRegistrationInput: PushRegistrationInput(
        (b) => b
          ..platform = platform == null
              ? null
              : PushRegistrationInputPlatformEnum.valueOf(platform)
          ..token = token
          ..enabled = enabled,
      ),
    ),
  )).data;
}

final ownerWatchApiProvider = Provider<OwnerWatchApi>(
  (ref) => ApiOwnerWatchApi(ref.watch(apiClientProvider)),
);
