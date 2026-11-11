// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_settings_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableSettingsResult extends TableSettingsResult {
  @override
  final TableSettings data;

  factory _$TableSettingsResult(
          [void Function(TableSettingsResultBuilder)? updates]) =>
      (TableSettingsResultBuilder()..update(updates))._build();

  _$TableSettingsResult._({required this.data}) : super._();
  @override
  TableSettingsResult rebuild(
          void Function(TableSettingsResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableSettingsResultBuilder toBuilder() =>
      TableSettingsResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableSettingsResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TableSettingsResult')
          ..add('data', data))
        .toString();
  }
}

class TableSettingsResultBuilder
    implements Builder<TableSettingsResult, TableSettingsResultBuilder> {
  _$TableSettingsResult? _$v;

  TableSettingsBuilder? _data;
  TableSettingsBuilder get data => _$this._data ??= TableSettingsBuilder();
  set data(TableSettingsBuilder? data) => _$this._data = data;

  TableSettingsResultBuilder() {
    TableSettingsResult._defaults(this);
  }

  TableSettingsResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableSettingsResult other) {
    _$v = other as _$TableSettingsResult;
  }

  @override
  void update(void Function(TableSettingsResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableSettingsResult build() => _build();

  _$TableSettingsResult _build() {
    _$TableSettingsResult _$result;
    try {
      _$result = _$v ??
          _$TableSettingsResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableSettingsResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
