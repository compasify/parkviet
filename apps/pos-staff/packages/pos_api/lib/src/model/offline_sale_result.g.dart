// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sale_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSaleResult extends OfflineSaleResult {
  @override
  final OfflineSale data;

  factory _$OfflineSaleResult(
          [void Function(OfflineSaleResultBuilder)? updates]) =>
      (OfflineSaleResultBuilder()..update(updates))._build();

  _$OfflineSaleResult._({required this.data}) : super._();
  @override
  OfflineSaleResult rebuild(void Function(OfflineSaleResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSaleResultBuilder toBuilder() =>
      OfflineSaleResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSaleResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OfflineSaleResult')
          ..add('data', data))
        .toString();
  }
}

class OfflineSaleResultBuilder
    implements Builder<OfflineSaleResult, OfflineSaleResultBuilder> {
  _$OfflineSaleResult? _$v;

  OfflineSaleBuilder? _data;
  OfflineSaleBuilder get data => _$this._data ??= OfflineSaleBuilder();
  set data(OfflineSaleBuilder? data) => _$this._data = data;

  OfflineSaleResultBuilder() {
    OfflineSaleResult._defaults(this);
  }

  OfflineSaleResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSaleResult other) {
    _$v = other as _$OfflineSaleResult;
  }

  @override
  void update(void Function(OfflineSaleResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSaleResult build() => _build();

  _$OfflineSaleResult _build() {
    _$OfflineSaleResult _$result;
    try {
      _$result = _$v ??
          _$OfflineSaleResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OfflineSaleResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
