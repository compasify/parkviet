// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_branch_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerBranchList extends OwnerBranchList {
  @override
  final BuiltList<OwnerBranch> data;

  factory _$OwnerBranchList([void Function(OwnerBranchListBuilder)? updates]) =>
      (OwnerBranchListBuilder()..update(updates))._build();

  _$OwnerBranchList._({required this.data}) : super._();
  @override
  OwnerBranchList rebuild(void Function(OwnerBranchListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerBranchListBuilder toBuilder() => OwnerBranchListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerBranchList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OwnerBranchList')..add('data', data))
        .toString();
  }
}

class OwnerBranchListBuilder
    implements Builder<OwnerBranchList, OwnerBranchListBuilder> {
  _$OwnerBranchList? _$v;

  ListBuilder<OwnerBranch>? _data;
  ListBuilder<OwnerBranch> get data =>
      _$this._data ??= ListBuilder<OwnerBranch>();
  set data(ListBuilder<OwnerBranch>? data) => _$this._data = data;

  OwnerBranchListBuilder() {
    OwnerBranchList._defaults(this);
  }

  OwnerBranchListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerBranchList other) {
    _$v = other as _$OwnerBranchList;
  }

  @override
  void update(void Function(OwnerBranchListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerBranchList build() => _build();

  _$OwnerBranchList _build() {
    _$OwnerBranchList _$result;
    try {
      _$result = _$v ??
          _$OwnerBranchList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnerBranchList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
