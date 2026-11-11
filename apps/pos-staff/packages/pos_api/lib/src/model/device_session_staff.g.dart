// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_session_staff.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceSessionStaff extends DeviceSessionStaff {
  @override
  final String id;
  @override
  final String? name;

  factory _$DeviceSessionStaff(
          [void Function(DeviceSessionStaffBuilder)? updates]) =>
      (DeviceSessionStaffBuilder()..update(updates))._build();

  _$DeviceSessionStaff._({required this.id, this.name}) : super._();
  @override
  DeviceSessionStaff rebuild(
          void Function(DeviceSessionStaffBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceSessionStaffBuilder toBuilder() =>
      DeviceSessionStaffBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceSessionStaff && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'DeviceSessionStaff')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class DeviceSessionStaffBuilder
    implements Builder<DeviceSessionStaff, DeviceSessionStaffBuilder> {
  _$DeviceSessionStaff? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DeviceSessionStaffBuilder() {
    DeviceSessionStaff._defaults(this);
  }

  DeviceSessionStaffBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceSessionStaff other) {
    _$v = other as _$DeviceSessionStaff;
  }

  @override
  void update(void Function(DeviceSessionStaffBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceSessionStaff build() => _build();

  _$DeviceSessionStaff _build() {
    final _$result = _$v ??
        _$DeviceSessionStaff._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'DeviceSessionStaff', 'id'),
          name: name,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
