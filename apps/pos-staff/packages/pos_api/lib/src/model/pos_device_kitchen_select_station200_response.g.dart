// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_kitchen_select_station200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDeviceKitchenSelectStation200Response
    extends PosDeviceKitchenSelectStation200Response {
  @override
  final Device data;

  factory _$PosDeviceKitchenSelectStation200Response(
          [void Function(PosDeviceKitchenSelectStation200ResponseBuilder)?
              updates]) =>
      (PosDeviceKitchenSelectStation200ResponseBuilder()..update(updates))
          ._build();

  _$PosDeviceKitchenSelectStation200Response._({required this.data})
      : super._();
  @override
  PosDeviceKitchenSelectStation200Response rebuild(
          void Function(PosDeviceKitchenSelectStation200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDeviceKitchenSelectStation200ResponseBuilder toBuilder() =>
      PosDeviceKitchenSelectStation200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDeviceKitchenSelectStation200Response &&
        data == other.data;
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
    return (newBuiltValueToStringHelper(
            r'PosDeviceKitchenSelectStation200Response')
          ..add('data', data))
        .toString();
  }
}

class PosDeviceKitchenSelectStation200ResponseBuilder
    implements
        Builder<PosDeviceKitchenSelectStation200Response,
            PosDeviceKitchenSelectStation200ResponseBuilder> {
  _$PosDeviceKitchenSelectStation200Response? _$v;

  DeviceBuilder? _data;
  DeviceBuilder get data => _$this._data ??= DeviceBuilder();
  set data(DeviceBuilder? data) => _$this._data = data;

  PosDeviceKitchenSelectStation200ResponseBuilder() {
    PosDeviceKitchenSelectStation200Response._defaults(this);
  }

  PosDeviceKitchenSelectStation200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDeviceKitchenSelectStation200Response other) {
    _$v = other as _$PosDeviceKitchenSelectStation200Response;
  }

  @override
  void update(
      void Function(PosDeviceKitchenSelectStation200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDeviceKitchenSelectStation200Response build() => _build();

  _$PosDeviceKitchenSelectStation200Response _build() {
    _$PosDeviceKitchenSelectStation200Response _$result;
    try {
      _$result = _$v ??
          _$PosDeviceKitchenSelectStation200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosDeviceKitchenSelectStation200Response',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
