// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_menu_categories200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosMenuCategories200Response extends PosMenuCategories200Response {
  @override
  final BuiltList<MenuCategory> data;

  factory _$PosMenuCategories200Response(
          [void Function(PosMenuCategories200ResponseBuilder)? updates]) =>
      (PosMenuCategories200ResponseBuilder()..update(updates))._build();

  _$PosMenuCategories200Response._({required this.data}) : super._();
  @override
  PosMenuCategories200Response rebuild(
          void Function(PosMenuCategories200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosMenuCategories200ResponseBuilder toBuilder() =>
      PosMenuCategories200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosMenuCategories200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosMenuCategories200Response')
          ..add('data', data))
        .toString();
  }
}

class PosMenuCategories200ResponseBuilder
    implements
        Builder<PosMenuCategories200Response,
            PosMenuCategories200ResponseBuilder> {
  _$PosMenuCategories200Response? _$v;

  ListBuilder<MenuCategory>? _data;
  ListBuilder<MenuCategory> get data =>
      _$this._data ??= ListBuilder<MenuCategory>();
  set data(ListBuilder<MenuCategory>? data) => _$this._data = data;

  PosMenuCategories200ResponseBuilder() {
    PosMenuCategories200Response._defaults(this);
  }

  PosMenuCategories200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosMenuCategories200Response other) {
    _$v = other as _$PosMenuCategories200Response;
  }

  @override
  void update(void Function(PosMenuCategories200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosMenuCategories200Response build() => _build();

  _$PosMenuCategories200Response _build() {
    _$PosMenuCategories200Response _$result;
    try {
      _$result = _$v ??
          _$PosMenuCategories200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosMenuCategories200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
