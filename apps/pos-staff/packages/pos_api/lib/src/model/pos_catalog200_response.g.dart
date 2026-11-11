// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_catalog200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosCatalog200Response extends PosCatalog200Response {
  @override
  final BuiltList<CatalogItem> data;

  factory _$PosCatalog200Response(
          [void Function(PosCatalog200ResponseBuilder)? updates]) =>
      (PosCatalog200ResponseBuilder()..update(updates))._build();

  _$PosCatalog200Response._({required this.data}) : super._();
  @override
  PosCatalog200Response rebuild(
          void Function(PosCatalog200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosCatalog200ResponseBuilder toBuilder() =>
      PosCatalog200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosCatalog200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosCatalog200Response')
          ..add('data', data))
        .toString();
  }
}

class PosCatalog200ResponseBuilder
    implements Builder<PosCatalog200Response, PosCatalog200ResponseBuilder> {
  _$PosCatalog200Response? _$v;

  ListBuilder<CatalogItem>? _data;
  ListBuilder<CatalogItem> get data =>
      _$this._data ??= ListBuilder<CatalogItem>();
  set data(ListBuilder<CatalogItem>? data) => _$this._data = data;

  PosCatalog200ResponseBuilder() {
    PosCatalog200Response._defaults(this);
  }

  PosCatalog200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosCatalog200Response other) {
    _$v = other as _$PosCatalog200Response;
  }

  @override
  void update(void Function(PosCatalog200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosCatalog200Response build() => _build();

  _$PosCatalog200Response _build() {
    _$PosCatalog200Response _$result;
    try {
      _$result = _$v ??
          _$PosCatalog200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosCatalog200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
