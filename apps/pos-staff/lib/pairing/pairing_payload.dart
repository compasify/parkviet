import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pairing_payload.freezed.dart';
part 'pairing_payload.g.dart';

/// The QR a manager shows to pair a device:
/// `{"v":1,"kind":"parkviet.device","url":"…","code":"…"}`.
@freezed
abstract class PairingPayload with _$PairingPayload {
  const factory PairingPayload({
    required int v,
    required String kind,
    required String url,
    required String code,
  }) = _PairingPayload;

  factory PairingPayload.fromJson(Map<String, Object?> json) => _$PairingPayloadFromJson(json);

  static const version = 1;
  static const deviceKind = 'parkviet.device';

  /// Reads a scanned QR. Throws [PairingPayloadError] for anything this app
  /// cannot pair with: another version, another kind of QR, a bad address.
  static PairingPayload parse(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const PairingPayloadError(PairingPayloadProblem.notPairingCode);
    }
    if (decoded is! Map<String, Object?>) {
      throw const PairingPayloadError(PairingPayloadProblem.notPairingCode);
    }
    final v = decoded['v'];
    if (v is! int) throw const PairingPayloadError(PairingPayloadProblem.notPairingCode);
    if (v != version) throw const PairingPayloadError(PairingPayloadProblem.unsupportedVersion);
    if (decoded['kind'] != deviceKind) throw const PairingPayloadError(PairingPayloadProblem.wrongKind);

    final PairingPayload payload;
    try {
      payload = PairingPayload.fromJson(decoded);
    } on Object {
      throw const PairingPayloadError(PairingPayloadProblem.notPairingCode);
    }
    if (payload.code.trim().isEmpty) throw const PairingPayloadError(PairingPayloadProblem.missingCode);
    return payload.copyWith(url: normalizeServerUrl(payload.url), code: payload.code.trim());
  }
}

enum PairingPayloadProblem { notPairingCode, unsupportedVersion, wrongKind, invalidUrl, insecureUrl, missingCode }

class PairingPayloadError implements Exception {
  const PairingPayloadError(this.problem);

  final PairingPayloadProblem problem;

  @override
  String toString() => 'PairingPayloadError(${problem.name})';
}

/// The server origin (and optional path) without a trailing slash. Only
/// http and https, with a host, and no credentials, query or fragment.
///
/// Plain http is accepted only for a shop server: a private IPv4 address
/// (10/8, 172.16/12, 192.168/16) or a `.local` name. The platform allows
/// cleartext to any host (Android cannot limit it by address range), so this
/// check is what keeps tokens off plain http across the internet.
String normalizeServerUrl(String input) {
  final uri = Uri.tryParse(input.trim());
  final valid = uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty &&
      !uri.hasQuery &&
      !uri.hasFragment;
  if (!valid) throw const PairingPayloadError(PairingPayloadProblem.invalidUrl);
  if (uri.scheme == 'http' && !isPrivateHost(uri.host)) {
    throw const PairingPayloadError(PairingPayloadProblem.insecureUrl);
  }

  var path = uri.path;
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return uri.replace(path: path).toString();
}

// No leading zeros: `010.0.0.1` reads as octal in some resolvers, so it may
// not be the private address it looks like. The server refuses it too.
final _ipv4 = RegExp(r'^(0|[1-9]\d{0,2})\.(0|[1-9]\d{0,2})\.(0|[1-9]\d{0,2})\.(0|[1-9]\d{0,2})$');
final _localName = RegExp(r'^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+local$', caseSensitive: false);

/// A host on the shop network: a private IPv4 address or a `.local` name.
/// Same rule as the server's POS_PUBLIC_BASE_URL check.
bool isPrivateHost(String host) {
  if (_localName.hasMatch(host)) return true;
  final match = _ipv4.firstMatch(host);
  if (match == null) return false;
  final octets = [for (var i = 1; i <= 4; i++) int.parse(match.group(i)!)];
  if (octets.any((octet) => octet > 255)) return false;
  final [a, b, ...] = octets;
  return a == 10 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168);
}
