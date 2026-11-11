import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// The few keys the app keeps. A key/value seam so tests use memory.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class PlatformSecretStore implements SecretStore {
  PlatformSecretStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

class MemorySecretStore implements SecretStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();
}

/// The iOS Keychain keeps this app's entries after an uninstall, so a
/// reinstalled app would come back paired with the old device token.
/// SharedPreferences go with the app on both platforms: no flag there means
/// this is the first launch of this install, and secure storage is wiped.
const installedFlag = 'installed';

Future<void> forgetPreviousInstall(SecretStore secrets, SharedPreferences preferences) async {
  if (preferences.getBool(installedFlag) == true) return;
  await secrets.deleteAll();
  await preferences.setBool(installedFlag, true);
}

class StoredPairing {
  const StoredPairing({required this.serverUrl, required this.deviceToken});

  final String serverUrl;
  final String deviceToken;
}

/// The pairing of this installation. Uninstalling the app loses it.
class DeviceStore {
  DeviceStore(this._store, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  static const _serverUrl = 'server_url';
  static const _deviceToken = 'device_token';
  static const _editorId = 'editor_id';

  final SecretStore _store;
  final Uuid _uuid;

  Future<StoredPairing?> readPairing() async {
    final url = await _store.read(_serverUrl);
    final token = await _store.read(_deviceToken);
    if (url == null || token == null) return null;
    return StoredPairing(serverUrl: url, deviceToken: token);
  }

  Future<void> savePairing(StoredPairing pairing) async {
    await _store.write(_serverUrl, pairing.serverUrl);
    await _store.write(_deviceToken, pairing.deviceToken);
    await editorId();
  }

  /// Forgets the server and token. The editor id belongs to the
  /// installation and stays.
  Future<void> clearPairing() async {
    await _store.delete(_deviceToken);
    await _store.delete(_serverUrl);
  }

  /// One UUID v4 per installation, created on first use; it identifies this
  /// device as an editor of an order.
  Future<String> editorId() async {
    final existing = await _store.read(_editorId);
    if (existing != null) return existing;
    final created = _uuid.v4();
    await _store.write(_editorId, created);
    return created;
  }
}
