// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_offline_sales200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosOfflineSales200Response extends PosOfflineSales200Response {
  @override
  final BuiltList<OfflineSale> data;

  factory _$PosOfflineSales200Response(
          [void Function(PosOfflineSales200ResponseBuilder)? updates]) =>
      (PosOfflineSales200ResponseBuilder()..update(updates))._build();

  _$PosOfflineSales200Response._({required this.data}) : super._();
  @override
  PosOfflineSales200Response rebuild(
          void Function(PosOfflineSales200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosOfflineSales200ResponseBuilder toBuilder() =>
      PosOfflineSales200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosOfflineSales200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosOfflineSales200Response')
          ..add('data', data))
        .toString();
  }
}

class PosOfflineSales200ResponseBuilder
    implements
        Builder<PosOfflineSales200Response, PosOfflineSales200ResponseBuilder> {
  _$PosOfflineSales200Response? _$v;

  ListBuilder<OfflineSale>? _data;
  ListBuilder<OfflineSale> get data =>
      _$this._data ??= ListBuilder<OfflineSale>();
  set data(ListBuilder<OfflineSale>? data) => _$this._data = data;

  PosOfflineSales200ResponseBuilder() {
    PosOfflineSales200Response._defaults(this);
  }

  PosOfflineSales200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosOfflineSales200Response other) {
    _$v = other as _$PosOfflineSales200Response;
  }

  @override
  void update(void Function(PosOfflineSales200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosOfflineSales200Response build() => _build();

  _$PosOfflineSales200Response _build() {
    _$PosOfflineSales200Response _$result;
    try {
      _$result = _$v ??
          _$PosOfflineSales200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosOfflineSales200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
