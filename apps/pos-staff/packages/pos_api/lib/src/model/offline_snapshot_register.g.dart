// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_snapshot_register.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSnapshotRegister extends OfflineSnapshotRegister {
  @override
  final String id;
  @override
  final String name;
  @override
  final String code;

  factory _$OfflineSnapshotRegister(
          [void Function(OfflineSnapshotRegisterBuilder)? updates]) =>
      (OfflineSnapshotRegisterBuilder()..update(updates))._build();

  _$OfflineSnapshotRegister._(
      {required this.id, required this.name, required this.code})
      : super._();
  @override
  OfflineSnapshotRegister rebuild(
          void Function(OfflineSnapshotRegisterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSnapshotRegisterBuilder toBuilder() =>
      OfflineSnapshotRegisterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSnapshotRegister &&
        id == other.id &&
        name == other.name &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSnapshotRegister')
          ..add('id', id)
          ..add('name', name)
          ..add('code', code))
        .toString();
  }
}

class OfflineSnapshotRegisterBuilder
    implements
        Builder<OfflineSnapshotRegister, OfflineSnapshotRegisterBuilder> {
  _$OfflineSnapshotRegister? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  OfflineSnapshotRegisterBuilder() {
    OfflineSnapshotRegister._defaults(this);
  }

  OfflineSnapshotRegisterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSnapshotRegister other) {
    _$v = other as _$OfflineSnapshotRegister;
  }

  @override
  void update(void Function(OfflineSnapshotRegisterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSnapshotRegister build() => _build();

  _$OfflineSnapshotRegister _build() {
    final _$result = _$v ??
        _$OfflineSnapshotRegister._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OfflineSnapshotRegister', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'OfflineSnapshotRegister', 'name'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'OfflineSnapshotRegister', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
