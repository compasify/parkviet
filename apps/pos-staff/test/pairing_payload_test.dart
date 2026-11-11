import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:parkviet_staff/pairing/pairing_payload.dart';

String qr(Map<String, Object?> payload) => jsonEncode(payload);

Matcher refusedFor(PairingPayloadProblem problem) =>
    throwsA(isA<PairingPayloadError>().having((error) => error.problem, 'problem', problem));

void main() {
  const valid = {'v': 1, 'kind': 'parkviet.device', 'url': 'http://192.168.1.10/', 'code': ' AB12CD34 '};

  test('reads the server payload and trims the url and code', () {
    final payload = PairingPayload.parse(qr(valid));
    expect(payload.url, 'http://192.168.1.10');
    expect(payload.code, 'AB12CD34');
  });

  test('accepts an https server under a path', () {
    final payload = PairingPayload.parse(qr({...valid, 'url': 'https://pos.example.vn/staff//'}));
    expect(payload.url, 'https://pos.example.vn/staff');
  });

  test('refuses a version it does not know', () {
    expect(() => PairingPayload.parse(qr({...valid, 'v': 2})), refusedFor(PairingPayloadProblem.unsupportedVersion));
  });

  test('refuses another kind of QR', () {
    expect(() => PairingPayload.parse(qr({...valid, 'kind': 'parkviet.display'})),
        refusedFor(PairingPayloadProblem.wrongKind));
    expect(() => PairingPayload.parse(qr({...valid}..remove('kind'))), refusedFor(PairingPayloadProblem.wrongKind));
  });

  test('refuses an address that is not http or https', () {
    for (final url in ['ftp://192.168.1.10', 'javascript:alert(1)', 'file:///etc/passwd', 'pos.local', '']) {
      expect(() => PairingPayload.parse(qr({...valid, 'url': url})), refusedFor(PairingPayloadProblem.invalidUrl),
          reason: url);
    }
  });

  test('accepts plain http only for a server on the shop network', () {
    for (final url in [
      'http://192.168.1.10',
      'http://10.0.2.2:3000',
      'http://172.16.0.1',
      'http://172.31.255.254',
      'http://pos.local',
      'http://may-chu.quan-a.local:8080',
    ]) {
      expect(normalizeServerUrl(url), url, reason: url);
    }
    expect(normalizeServerUrl('https://example.com'), 'https://example.com');
    expect(normalizeServerUrl('https://192.168.1.10'), 'https://192.168.1.10');
  });

  test('refuses plain http to a public host', () {
    for (final url in [
      'http://example.com',
      'http://8.8.8.8',
      'http://172.32.0.1',
      'http://172.15.0.1',
      'http://192.169.1.1',
      'http://localhost',
      'http://local',
      'http://192.168.1.300',
      'http://pos.local.example.com',
    ]) {
      expect(() => normalizeServerUrl(url), refusedFor(PairingPayloadProblem.insecureUrl), reason: url);
    }
    expect(() => PairingPayload.parse(qr({...valid, 'url': 'http://example.com'})),
        refusedFor(PairingPayloadProblem.insecureUrl));
  });

  test('refuses an IPv4 address written with leading zeros', () {
    for (final host in ['010.0.0.1', '172.016.0.1', '192.168.01.10', '10.0.0.01', '00.0.0.0']) {
      expect(isPrivateHost(host), isFalse, reason: host);
      expect(() => normalizeServerUrl('http://$host'), refusedFor(PairingPayloadProblem.insecureUrl), reason: host);
    }
    expect(isPrivateHost('10.0.0.1'), isTrue);
    expect(isPrivateHost('192.168.0.10'), isTrue);
  });

  test('refuses an address with credentials, a query or a fragment', () {
    for (final url in ['http://a:b@192.168.1.10', 'http://192.168.1.10/?x=1', 'http://192.168.1.10/#x']) {
      expect(() => PairingPayload.parse(qr({...valid, 'url': url})), refusedFor(PairingPayloadProblem.invalidUrl),
          reason: url);
    }
  });

  test('refuses text that is not a pairing payload', () {
    for (final raw in ['hello', '[1,2]', '{"v":"1"}', 'https://example.com']) {
      expect(() => PairingPayload.parse(raw), refusedFor(PairingPayloadProblem.notPairingCode), reason: raw);
    }
  });

  test('refuses a payload without a code', () {
    expect(() => PairingPayload.parse(qr({...valid, 'code': '  '})), refusedFor(PairingPayloadProblem.missingCode));
    expect(() => PairingPayload.parse(qr({...valid}..remove('code'))),
        refusedFor(PairingPayloadProblem.notPairingCode));
  });
}
