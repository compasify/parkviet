// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_staff_sign_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceStaffSignIn extends DeviceStaffSignIn {
  @override
  final String token;
  @override
  final DateTime expiresAt;
  @override
  final String staffId;
  @override
  final String? name;

  factory _$DeviceStaffSignIn(
          [void Function(DeviceStaffSignInBuilder)? updates]) =>
      (DeviceStaffSignInBuilder()..update(updates))._build();

  _$DeviceStaffSignIn._(
      {required this.token,
      required this.expiresAt,
      required this.staffId,
      this.name})
      : super._();
  @override
  DeviceStaffSignIn rebuild(void Function(DeviceStaffSignInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceStaffSignInBuilder toBuilder() =>
      DeviceStaffSignInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceStaffSignIn &&
        token == other.token &&
        expiresAt == other.expiresAt &&
        staffId == other.staffId &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, staffId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceStaffSignIn')
          ..add('token', token)
          ..add('expiresAt', expiresAt)
          ..add('staffId', staffId)
          ..add('name', name))
        .toString();
  }
}

class DeviceStaffSignInBuilder
    implements Builder<DeviceStaffSignIn, DeviceStaffSignInBuilder> {
  _$DeviceStaffSignIn? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _staffId;
  String? get staffId => _$this._staffId;
  set staffId(String? staffId) => _$this._staffId = staffId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DeviceStaffSignInBuilder() {
    DeviceStaffSignIn._defaults(this);
  }

  DeviceStaffSignInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _expiresAt = $v.expiresAt;
      _staffId = $v.staffId;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceStaffSignIn other) {
    _$v = other as _$DeviceStaffSignIn;
  }

  @override
  void update(void Function(DeviceStaffSignInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceStaffSignIn build() => _build();

  _$DeviceStaffSignIn _build() {
    final _$result = _$v ??
        _$DeviceStaffSignIn._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'DeviceStaffSignIn', 'token'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'DeviceStaffSignIn', 'expiresAt'),
          staffId: BuiltValueNullFieldError.checkNotNull(
              staffId, r'DeviceStaffSignIn', 'staffId'),
          name: name,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
