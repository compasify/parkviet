// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_snapshot_staff.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSnapshotStaff extends OfflineSnapshotStaff {
  @override
  final String id;
  @override
  final String? name;

  factory _$OfflineSnapshotStaff(
          [void Function(OfflineSnapshotStaffBuilder)? updates]) =>
      (OfflineSnapshotStaffBuilder()..update(updates))._build();

  _$OfflineSnapshotStaff._({required this.id, this.name}) : super._();
  @override
  OfflineSnapshotStaff rebuild(
          void Function(OfflineSnapshotStaffBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSnapshotStaffBuilder toBuilder() =>
      OfflineSnapshotStaffBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSnapshotStaff &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSnapshotStaff')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class OfflineSnapshotStaffBuilder
    implements Builder<OfflineSnapshotStaff, OfflineSnapshotStaffBuilder> {
  _$OfflineSnapshotStaff? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  OfflineSnapshotStaffBuilder() {
    OfflineSnapshotStaff._defaults(this);
  }

  OfflineSnapshotStaffBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSnapshotStaff other) {
    _$v = other as _$OfflineSnapshotStaff;
  }

  @override
  void update(void Function(OfflineSnapshotStaffBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSnapshotStaff build() => _build();

  _$OfflineSnapshotStaff _build() {
    final _$result = _$v ??
        _$OfflineSnapshotStaff._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OfflineSnapshotStaff', 'id'),
          name: name,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
