// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_tax_category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableTaxCategory extends TableTaxCategory {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? taxCode;
  @override
  final bool isDefault;

  factory _$TableTaxCategory(
          [void Function(TableTaxCategoryBuilder)? updates]) =>
      (TableTaxCategoryBuilder()..update(updates))._build();

  _$TableTaxCategory._(
      {required this.id,
      required this.name,
      this.taxCode,
      required this.isDefault})
      : super._();
  @override
  TableTaxCategory rebuild(void Function(TableTaxCategoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableTaxCategoryBuilder toBuilder() =>
      TableTaxCategoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableTaxCategory &&
        id == other.id &&
        name == other.name &&
        taxCode == other.taxCode &&
        isDefault == other.isDefault;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, taxCode.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableTaxCategory')
          ..add('id', id)
          ..add('name', name)
          ..add('taxCode', taxCode)
          ..add('isDefault', isDefault))
        .toString();
  }
}

class TableTaxCategoryBuilder
    implements Builder<TableTaxCategory, TableTaxCategoryBuilder> {
  _$TableTaxCategory? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _taxCode;
  String? get taxCode => _$this._taxCode;
  set taxCode(String? taxCode) => _$this._taxCode = taxCode;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  TableTaxCategoryBuilder() {
    TableTaxCategory._defaults(this);
  }

  TableTaxCategoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _taxCode = $v.taxCode;
      _isDefault = $v.isDefault;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableTaxCategory other) {
    _$v = other as _$TableTaxCategory;
  }

  @override
  void update(void Function(TableTaxCategoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableTaxCategory build() => _build();

  _$TableTaxCategory _build() {
    final _$result = _$v ??
        _$TableTaxCategory._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'TableTaxCategory', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TableTaxCategory', 'name'),
          taxCode: taxCode,
          isDefault: BuiltValueNullFieldError.checkNotNull(
              isDefault, r'TableTaxCategory', 'isDefault'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
