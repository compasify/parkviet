// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_menu_items200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosMenuItems200Response extends PosMenuItems200Response {
  @override
  final BuiltList<MenuItemConfig> data;

  factory _$PosMenuItems200Response(
          [void Function(PosMenuItems200ResponseBuilder)? updates]) =>
      (PosMenuItems200ResponseBuilder()..update(updates))._build();

  _$PosMenuItems200Response._({required this.data}) : super._();
  @override
  PosMenuItems200Response rebuild(
          void Function(PosMenuItems200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosMenuItems200ResponseBuilder toBuilder() =>
      PosMenuItems200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosMenuItems200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosMenuItems200Response')
          ..add('data', data))
        .toString();
  }
}

class PosMenuItems200ResponseBuilder
    implements
        Builder<PosMenuItems200Response, PosMenuItems200ResponseBuilder> {
  _$PosMenuItems200Response? _$v;

  ListBuilder<MenuItemConfig>? _data;
  ListBuilder<MenuItemConfig> get data =>
      _$this._data ??= ListBuilder<MenuItemConfig>();
  set data(ListBuilder<MenuItemConfig>? data) => _$this._data = data;

  PosMenuItems200ResponseBuilder() {
    PosMenuItems200Response._defaults(this);
  }

  PosMenuItems200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosMenuItems200Response other) {
    _$v = other as _$PosMenuItems200Response;
  }

  @override
  void update(void Function(PosMenuItems200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosMenuItems200Response build() => _build();

  _$PosMenuItems200Response _build() {
    _$PosMenuItems200Response _$result;
    try {
      _$result = _$v ??
          _$PosMenuItems200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosMenuItems200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
