// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_pins_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TablePinsResult extends TablePinsResult {
  @override
  final TablePins data;

  factory _$TablePinsResult([void Function(TablePinsResultBuilder)? updates]) =>
      (TablePinsResultBuilder()..update(updates))._build();

  _$TablePinsResult._({required this.data}) : super._();
  @override
  TablePinsResult rebuild(void Function(TablePinsResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TablePinsResultBuilder toBuilder() => TablePinsResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TablePinsResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TablePinsResult')..add('data', data))
        .toString();
  }
}

class TablePinsResultBuilder
    implements Builder<TablePinsResult, TablePinsResultBuilder> {
  _$TablePinsResult? _$v;

  TablePinsBuilder? _data;
  TablePinsBuilder get data => _$this._data ??= TablePinsBuilder();
  set data(TablePinsBuilder? data) => _$this._data = data;

  TablePinsResultBuilder() {
    TablePinsResult._defaults(this);
  }

  TablePinsResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TablePinsResult other) {
    _$v = other as _$TablePinsResult;
  }

  @override
  void update(void Function(TablePinsResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TablePinsResult build() => _build();

  _$TablePinsResult _build() {
    _$TablePinsResult _$result;
    try {
      _$result = _$v ??
          _$TablePinsResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TablePinsResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
