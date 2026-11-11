// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_me200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDeviceMe200Response extends PosDeviceMe200Response {
  @override
  final DeviceSession data;

  factory _$PosDeviceMe200Response(
          [void Function(PosDeviceMe200ResponseBuilder)? updates]) =>
      (PosDeviceMe200ResponseBuilder()..update(updates))._build();

  _$PosDeviceMe200Response._({required this.data}) : super._();
  @override
  PosDeviceMe200Response rebuild(
          void Function(PosDeviceMe200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDeviceMe200ResponseBuilder toBuilder() =>
      PosDeviceMe200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDeviceMe200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosDeviceMe200Response')
          ..add('data', data))
        .toString();
  }
}

class PosDeviceMe200ResponseBuilder
    implements Builder<PosDeviceMe200Response, PosDeviceMe200ResponseBuilder> {
  _$PosDeviceMe200Response? _$v;

  DeviceSessionBuilder? _data;
  DeviceSessionBuilder get data => _$this._data ??= DeviceSessionBuilder();
  set data(DeviceSessionBuilder? data) => _$this._data = data;

  PosDeviceMe200ResponseBuilder() {
    PosDeviceMe200Response._defaults(this);
  }

  PosDeviceMe200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDeviceMe200Response other) {
    _$v = other as _$PosDeviceMe200Response;
  }

  @override
  void update(void Function(PosDeviceMe200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDeviceMe200Response build() => _build();

  _$PosDeviceMe200Response _build() {
    _$PosDeviceMe200Response _$result;
    try {
      _$result = _$v ??
          _$PosDeviceMe200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosDeviceMe200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
