// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_session_branch.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceSessionBranch extends DeviceSessionBranch {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? timezone;

  factory _$DeviceSessionBranch(
          [void Function(DeviceSessionBranchBuilder)? updates]) =>
      (DeviceSessionBranchBuilder()..update(updates))._build();

  _$DeviceSessionBranch._({required this.id, required this.name, this.timezone})
      : super._();
  @override
  DeviceSessionBranch rebuild(
          void Function(DeviceSessionBranchBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceSessionBranchBuilder toBuilder() =>
      DeviceSessionBranchBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceSessionBranch &&
        id == other.id &&
        name == other.name &&
        timezone == other.timezone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceSessionBranch')
          ..add('id', id)
          ..add('name', name)
          ..add('timezone', timezone))
        .toString();
  }
}

class DeviceSessionBranchBuilder
    implements Builder<DeviceSessionBranch, DeviceSessionBranchBuilder> {
  _$DeviceSessionBranch? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  DeviceSessionBranchBuilder() {
    DeviceSessionBranch._defaults(this);
  }

  DeviceSessionBranchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _timezone = $v.timezone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceSessionBranch other) {
    _$v = other as _$DeviceSessionBranch;
  }

  @override
  void update(void Function(DeviceSessionBranchBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceSessionBranch build() => _build();

  _$DeviceSessionBranch _build() {
    final _$result = _$v ??
        _$DeviceSessionBranch._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'DeviceSessionBranch', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'DeviceSessionBranch', 'name'),
          timezone: timezone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
