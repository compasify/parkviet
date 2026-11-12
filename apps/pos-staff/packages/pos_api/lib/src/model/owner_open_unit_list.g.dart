// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_open_unit_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerOpenUnitList extends OwnerOpenUnitList {
  @override
  final BuiltList<OwnerOpenUnit> data;

  factory _$OwnerOpenUnitList(
          [void Function(OwnerOpenUnitListBuilder)? updates]) =>
      (OwnerOpenUnitListBuilder()..update(updates))._build();

  _$OwnerOpenUnitList._({required this.data}) : super._();
  @override
  OwnerOpenUnitList rebuild(void Function(OwnerOpenUnitListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerOpenUnitListBuilder toBuilder() =>
      OwnerOpenUnitListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerOpenUnitList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OwnerOpenUnitList')
          ..add('data', data))
        .toString();
  }
}

class OwnerOpenUnitListBuilder
    implements Builder<OwnerOpenUnitList, OwnerOpenUnitListBuilder> {
  _$OwnerOpenUnitList? _$v;

  ListBuilder<OwnerOpenUnit>? _data;
  ListBuilder<OwnerOpenUnit> get data =>
      _$this._data ??= ListBuilder<OwnerOpenUnit>();
  set data(ListBuilder<OwnerOpenUnit>? data) => _$this._data = data;

  OwnerOpenUnitListBuilder() {
    OwnerOpenUnitList._defaults(this);
  }

  OwnerOpenUnitListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerOpenUnitList other) {
    _$v = other as _$OwnerOpenUnitList;
  }

  @override
  void update(void Function(OwnerOpenUnitListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerOpenUnitList build() => _build();

  _$OwnerOpenUnitList _build() {
    _$OwnerOpenUnitList _$result;
    try {
      _$result = _$v ??
          _$OwnerOpenUnitList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnerOpenUnitList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
