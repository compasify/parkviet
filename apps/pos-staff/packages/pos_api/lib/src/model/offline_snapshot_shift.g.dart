// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_snapshot_shift.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSnapshotShift extends OfflineSnapshotShift {
  @override
  final String id;
  @override
  final DateTime? openedAt;

  factory _$OfflineSnapshotShift(
          [void Function(OfflineSnapshotShiftBuilder)? updates]) =>
      (OfflineSnapshotShiftBuilder()..update(updates))._build();

  _$OfflineSnapshotShift._({required this.id, this.openedAt}) : super._();
  @override
  OfflineSnapshotShift rebuild(
          void Function(OfflineSnapshotShiftBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSnapshotShiftBuilder toBuilder() =>
      OfflineSnapshotShiftBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSnapshotShift &&
        id == other.id &&
        openedAt == other.openedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, openedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSnapshotShift')
          ..add('id', id)
          ..add('openedAt', openedAt))
        .toString();
  }
}

class OfflineSnapshotShiftBuilder
    implements Builder<OfflineSnapshotShift, OfflineSnapshotShiftBuilder> {
  _$OfflineSnapshotShift? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _openedAt;
  DateTime? get openedAt => _$this._openedAt;
  set openedAt(DateTime? openedAt) => _$this._openedAt = openedAt;

  OfflineSnapshotShiftBuilder() {
    OfflineSnapshotShift._defaults(this);
  }

  OfflineSnapshotShiftBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _openedAt = $v.openedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSnapshotShift other) {
    _$v = other as _$OfflineSnapshotShift;
  }

  @override
  void update(void Function(OfflineSnapshotShiftBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSnapshotShift build() => _build();

  _$OfflineSnapshotShift _build() {
    final _$result = _$v ??
        _$OfflineSnapshotShift._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OfflineSnapshotShift', 'id'),
          openedAt: openedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
