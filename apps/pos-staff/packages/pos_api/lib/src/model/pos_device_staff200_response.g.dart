// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_staff200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDeviceStaff200Response extends PosDeviceStaff200Response {
  @override
  final BuiltList<DeviceStaffMember> data;

  factory _$PosDeviceStaff200Response(
          [void Function(PosDeviceStaff200ResponseBuilder)? updates]) =>
      (PosDeviceStaff200ResponseBuilder()..update(updates))._build();

  _$PosDeviceStaff200Response._({required this.data}) : super._();
  @override
  PosDeviceStaff200Response rebuild(
          void Function(PosDeviceStaff200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDeviceStaff200ResponseBuilder toBuilder() =>
      PosDeviceStaff200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDeviceStaff200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosDeviceStaff200Response')
          ..add('data', data))
        .toString();
  }
}

class PosDeviceStaff200ResponseBuilder
    implements
        Builder<PosDeviceStaff200Response, PosDeviceStaff200ResponseBuilder> {
  _$PosDeviceStaff200Response? _$v;

  ListBuilder<DeviceStaffMember>? _data;
  ListBuilder<DeviceStaffMember> get data =>
      _$this._data ??= ListBuilder<DeviceStaffMember>();
  set data(ListBuilder<DeviceStaffMember>? data) => _$this._data = data;

  PosDeviceStaff200ResponseBuilder() {
    PosDeviceStaff200Response._defaults(this);
  }

  PosDeviceStaff200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDeviceStaff200Response other) {
    _$v = other as _$PosDeviceStaff200Response;
  }

  @override
  void update(void Function(PosDeviceStaff200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDeviceStaff200Response build() => _build();

  _$PosDeviceStaff200Response _build() {
    _$PosDeviceStaff200Response _$result;
    try {
      _$result = _$v ??
          _$PosDeviceStaff200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosDeviceStaff200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
