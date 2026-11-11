// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AreaList extends AreaList {
  @override
  final BuiltList<Area> data;

  factory _$AreaList([void Function(AreaListBuilder)? updates]) =>
      (AreaListBuilder()..update(updates))._build();

  _$AreaList._({required this.data}) : super._();
  @override
  AreaList rebuild(void Function(AreaListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AreaListBuilder toBuilder() => AreaListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AreaList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'AreaList')..add('data', data))
        .toString();
  }
}

class AreaListBuilder implements Builder<AreaList, AreaListBuilder> {
  _$AreaList? _$v;

  ListBuilder<Area>? _data;
  ListBuilder<Area> get data => _$this._data ??= ListBuilder<Area>();
  set data(ListBuilder<Area>? data) => _$this._data = data;

  AreaListBuilder() {
    AreaList._defaults(this);
  }

  AreaListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AreaList other) {
    _$v = other as _$AreaList;
  }

  @override
  void update(void Function(AreaListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AreaList build() => _build();

  _$AreaList _build() {
    _$AreaList _$result;
    try {
      _$result = _$v ??
          _$AreaList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AreaList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
