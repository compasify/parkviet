// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_staff_sign_in201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDeviceStaffSignIn201Response
    extends PosDeviceStaffSignIn201Response {
  @override
  final DeviceStaffSignIn data;

  factory _$PosDeviceStaffSignIn201Response(
          [void Function(PosDeviceStaffSignIn201ResponseBuilder)? updates]) =>
      (PosDeviceStaffSignIn201ResponseBuilder()..update(updates))._build();

  _$PosDeviceStaffSignIn201Response._({required this.data}) : super._();
  @override
  PosDeviceStaffSignIn201Response rebuild(
          void Function(PosDeviceStaffSignIn201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDeviceStaffSignIn201ResponseBuilder toBuilder() =>
      PosDeviceStaffSignIn201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDeviceStaffSignIn201Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosDeviceStaffSignIn201Response')
          ..add('data', data))
        .toString();
  }
}

class PosDeviceStaffSignIn201ResponseBuilder
    implements
        Builder<PosDeviceStaffSignIn201Response,
            PosDeviceStaffSignIn201ResponseBuilder> {
  _$PosDeviceStaffSignIn201Response? _$v;

  DeviceStaffSignInBuilder? _data;
  DeviceStaffSignInBuilder get data =>
      _$this._data ??= DeviceStaffSignInBuilder();
  set data(DeviceStaffSignInBuilder? data) => _$this._data = data;

  PosDeviceStaffSignIn201ResponseBuilder() {
    PosDeviceStaffSignIn201Response._defaults(this);
  }

  PosDeviceStaffSignIn201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDeviceStaffSignIn201Response other) {
    _$v = other as _$PosDeviceStaffSignIn201Response;
  }

  @override
  void update(void Function(PosDeviceStaffSignIn201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDeviceStaffSignIn201Response build() => _build();

  _$PosDeviceStaffSignIn201Response _build() {
    _$PosDeviceStaffSignIn201Response _$result;
    try {
      _$result = _$v ??
          _$PosDeviceStaffSignIn201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosDeviceStaffSignIn201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
