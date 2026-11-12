// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_snapshot_branch.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSnapshotBranch extends OfflineSnapshotBranch {
  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String? timezone;

  factory _$OfflineSnapshotBranch(
          [void Function(OfflineSnapshotBranchBuilder)? updates]) =>
      (OfflineSnapshotBranchBuilder()..update(updates))._build();

  _$OfflineSnapshotBranch._(
      {required this.id, required this.name, required this.code, this.timezone})
      : super._();
  @override
  OfflineSnapshotBranch rebuild(
          void Function(OfflineSnapshotBranchBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSnapshotBranchBuilder toBuilder() =>
      OfflineSnapshotBranchBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSnapshotBranch &&
        id == other.id &&
        name == other.name &&
        code == other.code &&
        timezone == other.timezone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSnapshotBranch')
          ..add('id', id)
          ..add('name', name)
          ..add('code', code)
          ..add('timezone', timezone))
        .toString();
  }
}

class OfflineSnapshotBranchBuilder
    implements Builder<OfflineSnapshotBranch, OfflineSnapshotBranchBuilder> {
  _$OfflineSnapshotBranch? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  OfflineSnapshotBranchBuilder() {
    OfflineSnapshotBranch._defaults(this);
  }

  OfflineSnapshotBranchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _code = $v.code;
      _timezone = $v.timezone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSnapshotBranch other) {
    _$v = other as _$OfflineSnapshotBranch;
  }

  @override
  void update(void Function(OfflineSnapshotBranchBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSnapshotBranch build() => _build();

  _$OfflineSnapshotBranch _build() {
    final _$result = _$v ??
        _$OfflineSnapshotBranch._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OfflineSnapshotBranch', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'OfflineSnapshotBranch', 'name'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'OfflineSnapshotBranch', 'code'),
          timezone: timezone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
