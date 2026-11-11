import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_api/pos_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import '../core/errors.dart';
import '../core/session.dart';

part 'staff_session.freezed.dart';
part 'staff_session.g.dart';

@freezed
abstract class StaffSession with _$StaffSession {
  const factory StaffSession({
    required String staffId,
    String? name,
    required DateTime expiresAt,
  }) = _StaffSession;
}

/// The names at the branch, for the picker.
@riverpod
Future<List<DeviceStaffMember>> branchStaff(Ref ref) async {
  final response = await ref.watch(apiClientProvider).call((api) => api.posDeviceStaff());
  return response.data.toList();
}

/// The person signed in on this device, or null. Signs out after
/// [AppConfig.staffIdleTimeout] without a touch.
@Riverpod(keepAlive: true)
class StaffSessionController extends _$StaffSessionController {
  Timer? _idle;

  @override
  StaffSession? build() {
    ref.onDispose(() => _idle?.cancel());
    return null;
  }

  Future<void> signIn({required String membershipId, required String pin}) async {
    final opened = await openStaffSession(ref.read(apiClientProvider), membershipId: membershipId, pin: pin);
    ref.read(credentialsProvider).staffSessionToken = opened.token;
    state = StaffSession(staffId: opened.staffId, name: opened.name, expiresAt: opened.expiresAt);
    touch();
  }

  /// Any interaction keeps the session alive.
  void touch() {
    if (state == null) return;
    _idle?.cancel();
    final left = state!.expiresAt.difference(DateTime.now());
    _idle = Timer(left < AppConfig.staffIdleTimeout ? left : AppConfig.staffIdleTimeout, signOut);
  }

  Future<void> signOut() async {
    _idle?.cancel();
    final credentials = ref.read(credentialsProvider);
    final token = credentials.staffSessionToken;
    credentials.staffSessionToken = null;
    state = null;
    if (token != null) await closeStaffSession(ref.read(apiClientProvider), token);
  }

  /// The server no longer knows the session; forget it here too.
  void dropped() {
    _idle?.cancel();
    ref.read(credentialsProvider).staffSessionToken = null;
    state = null;
  }
}

Future<DeviceStaffSignIn> openStaffSession(
  PosApiClient client, {
  required String membershipId,
  required String pin,
}) async {
  final response = await client.call((api) => api.posDeviceStaffSignIn(
        posDeviceStaffSignInRequest: PosDeviceStaffSignInRequest((b) => b
          ..membershipId = membershipId
          ..pin = pin),
      ));
  return response.data;
}

/// Ends a session on the server. Best effort: an unreachable server ends it
/// on its own after the idle limit.
Future<void> closeStaffSession(PosApiClient client, String token) async {
  try {
    await client.call((api) => api.posDeviceStaffSignOut(headers: {staffSessionHeader: token}));
  } on AppFailure {
    // Expires on the server by itself.
  }
}

/// Whether this PIN belongs to someone who may manage devices at the
/// branch. The session it opens is closed again at once.
Future<bool> verifyManager(
  PosApiClient client, {
  required String branchId,
  required String membershipId,
  required String pin,
}) async {
  final opened = await openStaffSession(client, membershipId: membershipId, pin: pin);
  try {
    final context = await client.call((api) => api.posContext(
          branchId: branchId,
          headers: {staffSessionHeader: opened.token},
        ));
    return context.capabilities.contains(managerCapability);
  } on ForbiddenFailure {
    return false;
  } finally {
    await closeStaffSession(client, opened.token);
  }
}

const managerCapability = 'pos.device.manage';
