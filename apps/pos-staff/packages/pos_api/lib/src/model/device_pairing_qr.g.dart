// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_pairing_qr.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DevicePairingQr extends DevicePairingQr {
  @override
  final int v;
  @override
  final String kind;
  @override
  final String url;
  @override
  final String code;

  factory _$DevicePairingQr([void Function(DevicePairingQrBuilder)? updates]) =>
      (DevicePairingQrBuilder()..update(updates))._build();

  _$DevicePairingQr._(
      {required this.v,
      required this.kind,
      required this.url,
      required this.code})
      : super._();
  @override
  DevicePairingQr rebuild(void Function(DevicePairingQrBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DevicePairingQrBuilder toBuilder() => DevicePairingQrBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DevicePairingQr &&
        v == other.v &&
        kind == other.kind &&
        url == other.url &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, v.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DevicePairingQr')
          ..add('v', v)
          ..add('kind', kind)
          ..add('url', url)
          ..add('code', code))
        .toString();
  }
}

class DevicePairingQrBuilder
    implements Builder<DevicePairingQr, DevicePairingQrBuilder> {
  _$DevicePairingQr? _$v;

  int? _v;
  int? get v => _$this._v;
  set v(int? v) => _$this._v = v;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  DevicePairingQrBuilder() {
    DevicePairingQr._defaults(this);
  }

  DevicePairingQrBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _v = $v.v;
      _kind = $v.kind;
      _url = $v.url;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DevicePairingQr other) {
    _$v = other as _$DevicePairingQr;
  }

  @override
  void update(void Function(DevicePairingQrBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DevicePairingQr build() => _build();

  _$DevicePairingQr _build() {
    final _$result = _$v ??
        _$DevicePairingQr._(
          v: BuiltValueNullFieldError.checkNotNull(v, r'DevicePairingQr', 'v'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'DevicePairingQr', 'kind'),
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'DevicePairingQr', 'url'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'DevicePairingQr', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
