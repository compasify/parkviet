// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buffet_tier_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BuffetTierList extends BuffetTierList {
  @override
  final BuiltList<BuffetTier> data;

  factory _$BuffetTierList([void Function(BuffetTierListBuilder)? updates]) =>
      (BuffetTierListBuilder()..update(updates))._build();

  _$BuffetTierList._({required this.data}) : super._();
  @override
  BuffetTierList rebuild(void Function(BuffetTierListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuffetTierListBuilder toBuilder() => BuffetTierListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BuffetTierList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'BuffetTierList')..add('data', data))
        .toString();
  }
}

class BuffetTierListBuilder
    implements Builder<BuffetTierList, BuffetTierListBuilder> {
  _$BuffetTierList? _$v;

  ListBuilder<BuffetTier>? _data;
  ListBuilder<BuffetTier> get data =>
      _$this._data ??= ListBuilder<BuffetTier>();
  set data(ListBuilder<BuffetTier>? data) => _$this._data = data;

  BuffetTierListBuilder() {
    BuffetTierList._defaults(this);
  }

  BuffetTierListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuffetTierList other) {
    _$v = other as _$BuffetTierList;
  }

  @override
  void update(void Function(BuffetTierListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BuffetTierList build() => _build();

  _$BuffetTierList _build() {
    _$BuffetTierList _$result;
    try {
      _$result = _$v ??
          _$BuffetTierList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BuffetTierList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
