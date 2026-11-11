// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kitchen_settings200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKitchenSettings200Response extends PosKitchenSettings200Response {
  @override
  final KitchenSettings data;

  factory _$PosKitchenSettings200Response(
          [void Function(PosKitchenSettings200ResponseBuilder)? updates]) =>
      (PosKitchenSettings200ResponseBuilder()..update(updates))._build();

  _$PosKitchenSettings200Response._({required this.data}) : super._();
  @override
  PosKitchenSettings200Response rebuild(
          void Function(PosKitchenSettings200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKitchenSettings200ResponseBuilder toBuilder() =>
      PosKitchenSettings200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKitchenSettings200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosKitchenSettings200Response')
          ..add('data', data))
        .toString();
  }
}

class PosKitchenSettings200ResponseBuilder
    implements
        Builder<PosKitchenSettings200Response,
            PosKitchenSettings200ResponseBuilder> {
  _$PosKitchenSettings200Response? _$v;

  KitchenSettingsBuilder? _data;
  KitchenSettingsBuilder get data => _$this._data ??= KitchenSettingsBuilder();
  set data(KitchenSettingsBuilder? data) => _$this._data = data;

  PosKitchenSettings200ResponseBuilder() {
    PosKitchenSettings200Response._defaults(this);
  }

  PosKitchenSettings200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKitchenSettings200Response other) {
    _$v = other as _$PosKitchenSettings200Response;
  }

  @override
  void update(void Function(PosKitchenSettings200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKitchenSettings200Response build() => _build();

  _$PosKitchenSettings200Response _build() {
    _$PosKitchenSettings200Response _$result;
    try {
      _$result = _$v ??
          _$PosKitchenSettings200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKitchenSettings200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
