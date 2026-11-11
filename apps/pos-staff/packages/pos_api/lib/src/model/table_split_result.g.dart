// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_split_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableSplitResult extends TableSplitResult {
  @override
  final TableSplitOrders data;

  factory _$TableSplitResult(
          [void Function(TableSplitResultBuilder)? updates]) =>
      (TableSplitResultBuilder()..update(updates))._build();

  _$TableSplitResult._({required this.data}) : super._();
  @override
  TableSplitResult rebuild(void Function(TableSplitResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableSplitResultBuilder toBuilder() =>
      TableSplitResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableSplitResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TableSplitResult')..add('data', data))
        .toString();
  }
}

class TableSplitResultBuilder
    implements Builder<TableSplitResult, TableSplitResultBuilder> {
  _$TableSplitResult? _$v;

  TableSplitOrdersBuilder? _data;
  TableSplitOrdersBuilder get data =>
      _$this._data ??= TableSplitOrdersBuilder();
  set data(TableSplitOrdersBuilder? data) => _$this._data = data;

  TableSplitResultBuilder() {
    TableSplitResult._defaults(this);
  }

  TableSplitResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableSplitResult other) {
    _$v = other as _$TableSplitResult;
  }

  @override
  void update(void Function(TableSplitResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableSplitResult build() => _build();

  _$TableSplitResult _build() {
    _$TableSplitResult _$result;
    try {
      _$result = _$v ??
          _$TableSplitResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableSplitResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
