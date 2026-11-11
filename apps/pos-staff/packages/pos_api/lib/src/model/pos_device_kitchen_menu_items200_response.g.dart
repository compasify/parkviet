// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_kitchen_menu_items200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDeviceKitchenMenuItems200Response
    extends PosDeviceKitchenMenuItems200Response {
  @override
  final BuiltList<KitchenMenuItem> data;

  factory _$PosDeviceKitchenMenuItems200Response(
          [void Function(PosDeviceKitchenMenuItems200ResponseBuilder)?
              updates]) =>
      (PosDeviceKitchenMenuItems200ResponseBuilder()..update(updates))._build();

  _$PosDeviceKitchenMenuItems200Response._({required this.data}) : super._();
  @override
  PosDeviceKitchenMenuItems200Response rebuild(
          void Function(PosDeviceKitchenMenuItems200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDeviceKitchenMenuItems200ResponseBuilder toBuilder() =>
      PosDeviceKitchenMenuItems200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDeviceKitchenMenuItems200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosDeviceKitchenMenuItems200Response')
          ..add('data', data))
        .toString();
  }
}

class PosDeviceKitchenMenuItems200ResponseBuilder
    implements
        Builder<PosDeviceKitchenMenuItems200Response,
            PosDeviceKitchenMenuItems200ResponseBuilder> {
  _$PosDeviceKitchenMenuItems200Response? _$v;

  ListBuilder<KitchenMenuItem>? _data;
  ListBuilder<KitchenMenuItem> get data =>
      _$this._data ??= ListBuilder<KitchenMenuItem>();
  set data(ListBuilder<KitchenMenuItem>? data) => _$this._data = data;

  PosDeviceKitchenMenuItems200ResponseBuilder() {
    PosDeviceKitchenMenuItems200Response._defaults(this);
  }

  PosDeviceKitchenMenuItems200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDeviceKitchenMenuItems200Response other) {
    _$v = other as _$PosDeviceKitchenMenuItems200Response;
  }

  @override
  void update(
      void Function(PosDeviceKitchenMenuItems200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDeviceKitchenMenuItems200Response build() => _build();

  _$PosDeviceKitchenMenuItems200Response _build() {
    _$PosDeviceKitchenMenuItems200Response _$result;
    try {
      _$result = _$v ??
          _$PosDeviceKitchenMenuItems200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosDeviceKitchenMenuItems200Response',
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
