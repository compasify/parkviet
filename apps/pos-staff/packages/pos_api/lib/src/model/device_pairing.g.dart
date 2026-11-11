// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_pairing.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DevicePairing extends DevicePairing {
  @override
  final String id;
  @override
  final String code;
  @override
  final String expiresAt;
  @override
  final String mode;
  @override
  final DevicePairingQr qr;

  factory _$DevicePairing([void Function(DevicePairingBuilder)? updates]) =>
      (DevicePairingBuilder()..update(updates))._build();

  _$DevicePairing._(
      {required this.id,
      required this.code,
      required this.expiresAt,
      required this.mode,
      required this.qr})
      : super._();
  @override
  DevicePairing rebuild(void Function(DevicePairingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DevicePairingBuilder toBuilder() => DevicePairingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DevicePairing &&
        id == other.id &&
        code == other.code &&
        expiresAt == other.expiresAt &&
        mode == other.mode &&
        qr == other.qr;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, qr.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DevicePairing')
          ..add('id', id)
          ..add('code', code)
          ..add('expiresAt', expiresAt)
          ..add('mode', mode)
          ..add('qr', qr))
        .toString();
  }
}

class DevicePairingBuilder
    implements Builder<DevicePairing, DevicePairingBuilder> {
  _$DevicePairing? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _expiresAt;
  String? get expiresAt => _$this._expiresAt;
  set expiresAt(String? expiresAt) => _$this._expiresAt = expiresAt;

  String? _mode;
  String? get mode => _$this._mode;
  set mode(String? mode) => _$this._mode = mode;

  DevicePairingQrBuilder? _qr;
  DevicePairingQrBuilder get qr => _$this._qr ??= DevicePairingQrBuilder();
  set qr(DevicePairingQrBuilder? qr) => _$this._qr = qr;

  DevicePairingBuilder() {
    DevicePairing._defaults(this);
  }

  DevicePairingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _code = $v.code;
      _expiresAt = $v.expiresAt;
      _mode = $v.mode;
      _qr = $v.qr.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DevicePairing other) {
    _$v = other as _$DevicePairing;
  }

  @override
  void update(void Function(DevicePairingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DevicePairing build() => _build();

  _$DevicePairing _build() {
    _$DevicePairing _$result;
    try {
      _$result = _$v ??
          _$DevicePairing._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'DevicePairing', 'id'),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'DevicePairing', 'code'),
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'DevicePairing', 'expiresAt'),
            mode: BuiltValueNullFieldError.checkNotNull(
                mode, r'DevicePairing', 'mode'),
            qr: qr.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qr';
        qr.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DevicePairing', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
