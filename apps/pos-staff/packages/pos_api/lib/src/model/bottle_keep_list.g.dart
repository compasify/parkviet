// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle_keep_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BottleKeepList extends BottleKeepList {
  @override
  final BuiltList<BottleKeep> data;

  factory _$BottleKeepList([void Function(BottleKeepListBuilder)? updates]) =>
      (BottleKeepListBuilder()..update(updates))._build();

  _$BottleKeepList._({required this.data}) : super._();
  @override
  BottleKeepList rebuild(void Function(BottleKeepListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BottleKeepListBuilder toBuilder() => BottleKeepListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BottleKeepList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'BottleKeepList')..add('data', data))
        .toString();
  }
}

class BottleKeepListBuilder
    implements Builder<BottleKeepList, BottleKeepListBuilder> {
  _$BottleKeepList? _$v;

  ListBuilder<BottleKeep>? _data;
  ListBuilder<BottleKeep> get data =>
      _$this._data ??= ListBuilder<BottleKeep>();
  set data(ListBuilder<BottleKeep>? data) => _$this._data = data;

  BottleKeepListBuilder() {
    BottleKeepList._defaults(this);
  }

  BottleKeepListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BottleKeepList other) {
    _$v = other as _$BottleKeepList;
  }

  @override
  void update(void Function(BottleKeepListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BottleKeepList build() => _build();

  _$BottleKeepList _build() {
    _$BottleKeepList _$result;
    try {
      _$result = _$v ??
          _$BottleKeepList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BottleKeepList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
