// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_code_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableCodeEntry extends TableCodeEntry {
  @override
  final String resourceId;
  @override
  final String name;
  @override
  final String areaId;
  @override
  final TableCode? tableCode;

  factory _$TableCodeEntry([void Function(TableCodeEntryBuilder)? updates]) =>
      (TableCodeEntryBuilder()..update(updates))._build();

  _$TableCodeEntry._(
      {required this.resourceId,
      required this.name,
      required this.areaId,
      this.tableCode})
      : super._();
  @override
  TableCodeEntry rebuild(void Function(TableCodeEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableCodeEntryBuilder toBuilder() => TableCodeEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableCodeEntry &&
        resourceId == other.resourceId &&
        name == other.name &&
        areaId == other.areaId &&
        tableCode == other.tableCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jc(_$hash, tableCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableCodeEntry')
          ..add('resourceId', resourceId)
          ..add('name', name)
          ..add('areaId', areaId)
          ..add('tableCode', tableCode))
        .toString();
  }
}

class TableCodeEntryBuilder
    implements Builder<TableCodeEntry, TableCodeEntryBuilder> {
  _$TableCodeEntry? _$v;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  TableCodeBuilder? _tableCode;
  TableCodeBuilder get tableCode => _$this._tableCode ??= TableCodeBuilder();
  set tableCode(TableCodeBuilder? tableCode) => _$this._tableCode = tableCode;

  TableCodeEntryBuilder() {
    TableCodeEntry._defaults(this);
  }

  TableCodeEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _resourceId = $v.resourceId;
      _name = $v.name;
      _areaId = $v.areaId;
      _tableCode = $v.tableCode?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableCodeEntry other) {
    _$v = other as _$TableCodeEntry;
  }

  @override
  void update(void Function(TableCodeEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableCodeEntry build() => _build();

  _$TableCodeEntry _build() {
    _$TableCodeEntry _$result;
    try {
      _$result = _$v ??
          _$TableCodeEntry._(
            resourceId: BuiltValueNullFieldError.checkNotNull(
                resourceId, r'TableCodeEntry', 'resourceId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'TableCodeEntry', 'name'),
            areaId: BuiltValueNullFieldError.checkNotNull(
                areaId, r'TableCodeEntry', 'areaId'),
            tableCode: _tableCode?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tableCode';
        _tableCode?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableCodeEntry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
