import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/core/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('forgetPreviousInstall', () {
    test('wipes secrets a previous install left in the keychain on first launch', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final secrets = MemorySecretStore()
        ..values.addAll({'server_url': 'https://pos.quan-a.vn', 'device_token': 'old-token', 'editor_id': 'old-editor'});

      await forgetPreviousInstall(secrets, preferences);

      expect(secrets.values, isEmpty);
      expect(preferences.getBool(installedFlag), isTrue);
    });

    test('keeps the pairing on every later launch', () async {
      SharedPreferences.setMockInitialValues({installedFlag: true});
      final preferences = await SharedPreferences.getInstance();
      final secrets = MemorySecretStore()..values.addAll({'device_token': 'current-token'});

      await forgetPreviousInstall(secrets, preferences);

      expect(secrets.values, {'device_token': 'current-token'});
    });
  });
}
