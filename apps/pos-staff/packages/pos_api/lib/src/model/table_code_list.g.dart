// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_code_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableCodeList extends TableCodeList {
  @override
  final BuiltList<TableCodeEntry> data;

  factory _$TableCodeList([void Function(TableCodeListBuilder)? updates]) =>
      (TableCodeListBuilder()..update(updates))._build();

  _$TableCodeList._({required this.data}) : super._();
  @override
  TableCodeList rebuild(void Function(TableCodeListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableCodeListBuilder toBuilder() => TableCodeListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableCodeList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TableCodeList')..add('data', data))
        .toString();
  }
}

class TableCodeListBuilder
    implements Builder<TableCodeList, TableCodeListBuilder> {
  _$TableCodeList? _$v;

  ListBuilder<TableCodeEntry>? _data;
  ListBuilder<TableCodeEntry> get data =>
      _$this._data ??= ListBuilder<TableCodeEntry>();
  set data(ListBuilder<TableCodeEntry>? data) => _$this._data = data;

  TableCodeListBuilder() {
    TableCodeList._defaults(this);
  }

  TableCodeListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableCodeList other) {
    _$v = other as _$TableCodeList;
  }

  @override
  void update(void Function(TableCodeListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableCodeList build() => _build();

  _$TableCodeList _build() {
    _$TableCodeList _$result;
    try {
      _$result = _$v ??
          _$TableCodeList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableCodeList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
