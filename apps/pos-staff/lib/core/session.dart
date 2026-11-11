import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_api/pos_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pairing/pairing_payload.dart';
import 'api_client.dart';
import 'device_info.dart';
import 'errors.dart';
import 'secure_storage.dart';
import 'server_time.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// Where this installation stands with its server.
@freezed
sealed class AppSession with _$AppSession {
  /// No pairing. [revoked] when the server refused the stored token.
  const factory AppSession.unpaired({@Default(false) bool revoked}) = Unpaired;

  /// Paired, but the server could not be asked who this device is.
  const factory AppSession.offline({required String serverUrl, required AppFailure failure}) = Offline;

  const factory AppSession.paired({
    required String serverUrl,
    required DeviceSession me,
    required ServerClock clock,
  }) = Paired;
}

@Riverpod(keepAlive: true)
DeviceStore deviceStore(Ref ref) => DeviceStore(PlatformSecretStore());

@Riverpod(keepAlive: true)
DeviceCredentials credentials(Ref ref) => DeviceCredentials();

@Riverpod(keepAlive: true)
Future<DeviceDescriptor> deviceDescriptor(Ref ref) => DeviceDescriptor.load();

typedef ApiClientFactory = PosApiClient Function(String serverUrl);

@Riverpod(keepAlive: true)
ApiClientFactory apiClientFactory(Ref ref) {
  final credentials = ref.watch(credentialsProvider);
  return (serverUrl) => PosApiClient(baseUrl: serverUrl, credentials: credentials);
}

/// The client of the paired server. Only read it while paired.
@Riverpod(keepAlive: true)
PosApiClient apiClient(Ref ref) {
  final session = ref.watch(sessionProvider).value;
  if (session is! Paired) throw StateError('No paired server.');
  return ref.watch(apiClientFactoryProvider)(session.serverUrl);
}

@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  Future<AppSession> build() async {
    final stored = await ref.read(deviceStoreProvider).readPairing();
    if (stored == null) return const AppSession.unpaired();
    ref.read(credentialsProvider).deviceToken = stored.deviceToken;
    return _load(stored.serverUrl);
  }

  /// Checks the server, exchanges the code and keeps the token. Throws an
  /// [AppFailure] or [PairingPayloadError] for the screen to explain.
  Future<void> pair({required String serverUrl, required String code, String? name}) async {
    final url = normalizeServerUrl(serverUrl);
    final descriptor = await ref.read(deviceDescriptorProvider.future);
    final credentials = ref.read(credentialsProvider)..clear();
    final client = ref.read(apiClientFactoryProvider)(url);

    await client.checkUp();
    final label = (name ?? '').trim().isEmpty ? descriptor.model : name!.trim();
    final result = await client.call((api) => api.posDevicePair(
          posDevicePairRequest: PosDevicePairRequest((b) => b
            ..code = code.trim()
            ..platform = PosDevicePairRequestPlatformEnum.valueOf(descriptor.platform)
            ..name = label.length > 80 ? label.substring(0, 80) : label
            ..appVersion = descriptor.appVersion),
        ));
    final token = result.data.token;
    await ref.read(deviceStoreProvider).savePairing(StoredPairing(serverUrl: url, deviceToken: token));
    credentials.deviceToken = token;
    state = AsyncData(await _load(url));
  }

  Future<void> retry() async {
    final current = state.value;
    if (current is! Offline) return;
    state = const AsyncLoading();
    state = AsyncData(await _load(current.serverUrl));
  }

  /// Forgets the pairing on this device. Revoking it on the server is done
  /// from the management pages.
  Future<void> unpair({bool revoked = false}) async {
    await ref.read(deviceStoreProvider).clearPairing();
    ref.read(credentialsProvider).clear();
    state = AsyncData(AppSession.unpaired(revoked: revoked));
  }

  Future<AppSession> _load(String serverUrl) async {
    final client = ref.read(apiClientFactoryProvider)(serverUrl);
    try {
      final sentAt = DateTime.now();
      final response = await client.call((api) => api.posDeviceMe());
      final clock = ServerClock.measure(
        serverTime: response.data.serverTime,
        sentAt: sentAt,
        receivedAt: DateTime.now(),
      );
      return AppSession.paired(serverUrl: serverUrl, me: response.data, clock: clock);
    } on UnauthorizedFailure {
      await ref.read(deviceStoreProvider).clearPairing();
      ref.read(credentialsProvider).clear();
      return const AppSession.unpaired(revoked: true);
    } on AppFailure catch (failure) {
      return AppSession.offline(serverUrl: serverUrl, failure: failure);
    }
  }
}
