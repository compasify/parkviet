// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_staff_sign_in_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDeviceStaffSignInRequest extends PosDeviceStaffSignInRequest {
  @override
  final String membershipId;
  @override
  final String pin;

  factory _$PosDeviceStaffSignInRequest(
          [void Function(PosDeviceStaffSignInRequestBuilder)? updates]) =>
      (PosDeviceStaffSignInRequestBuilder()..update(updates))._build();

  _$PosDeviceStaffSignInRequest._(
      {required this.membershipId, required this.pin})
      : super._();
  @override
  PosDeviceStaffSignInRequest rebuild(
          void Function(PosDeviceStaffSignInRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDeviceStaffSignInRequestBuilder toBuilder() =>
      PosDeviceStaffSignInRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDeviceStaffSignInRequest &&
        membershipId == other.membershipId &&
        pin == other.pin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, membershipId.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosDeviceStaffSignInRequest')
          ..add('membershipId', membershipId)
          ..add('pin', pin))
        .toString();
  }
}

class PosDeviceStaffSignInRequestBuilder
    implements
        Builder<PosDeviceStaffSignInRequest,
            PosDeviceStaffSignInRequestBuilder> {
  _$PosDeviceStaffSignInRequest? _$v;

  String? _membershipId;
  String? get membershipId => _$this._membershipId;
  set membershipId(String? membershipId) => _$this._membershipId = membershipId;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  PosDeviceStaffSignInRequestBuilder() {
    PosDeviceStaffSignInRequest._defaults(this);
  }

  PosDeviceStaffSignInRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _membershipId = $v.membershipId;
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDeviceStaffSignInRequest other) {
    _$v = other as _$PosDeviceStaffSignInRequest;
  }

  @override
  void update(void Function(PosDeviceStaffSignInRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDeviceStaffSignInRequest build() => _build();

  _$PosDeviceStaffSignInRequest _build() {
    final _$result = _$v ??
        _$PosDeviceStaffSignInRequest._(
          membershipId: BuiltValueNullFieldError.checkNotNull(
              membershipId, r'PosDeviceStaffSignInRequest', 'membershipId'),
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'PosDeviceStaffSignInRequest', 'pin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
