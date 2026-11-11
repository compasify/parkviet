// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceSession extends DeviceSession {
  @override
  final Device device;
  @override
  final DeviceSessionBranch branch;
  @override
  final String? registerId;
  @override
  final String? kitchenStationId;
  @override
  final DeviceSessionStaff? staff;
  @override
  final DateTime serverTime;

  factory _$DeviceSession([void Function(DeviceSessionBuilder)? updates]) =>
      (DeviceSessionBuilder()..update(updates))._build();

  _$DeviceSession._(
      {required this.device,
      required this.branch,
      this.registerId,
      this.kitchenStationId,
      this.staff,
      required this.serverTime})
      : super._();
  @override
  DeviceSession rebuild(void Function(DeviceSessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceSessionBuilder toBuilder() => DeviceSessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceSession &&
        device == other.device &&
        branch == other.branch &&
        registerId == other.registerId &&
        kitchenStationId == other.kitchenStationId &&
        staff == other.staff &&
        serverTime == other.serverTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, device.hashCode);
    _$hash = $jc(_$hash, branch.hashCode);
    _$hash = $jc(_$hash, registerId.hashCode);
    _$hash = $jc(_$hash, kitchenStationId.hashCode);
    _$hash = $jc(_$hash, staff.hashCode);
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceSession')
          ..add('device', device)
          ..add('branch', branch)
          ..add('registerId', registerId)
          ..add('kitchenStationId', kitchenStationId)
          ..add('staff', staff)
          ..add('serverTime', serverTime))
        .toString();
  }
}

class DeviceSessionBuilder
    implements Builder<DeviceSession, DeviceSessionBuilder> {
  _$DeviceSession? _$v;

  DeviceBuilder? _device;
  DeviceBuilder get device => _$this._device ??= DeviceBuilder();
  set device(DeviceBuilder? device) => _$this._device = device;

  DeviceSessionBranchBuilder? _branch;
  DeviceSessionBranchBuilder get branch =>
      _$this._branch ??= DeviceSessionBranchBuilder();
  set branch(DeviceSessionBranchBuilder? branch) => _$this._branch = branch;

  String? _registerId;
  String? get registerId => _$this._registerId;
  set registerId(String? registerId) => _$this._registerId = registerId;

  String? _kitchenStationId;
  String? get kitchenStationId => _$this._kitchenStationId;
  set kitchenStationId(String? kitchenStationId) =>
      _$this._kitchenStationId = kitchenStationId;

  DeviceSessionStaffBuilder? _staff;
  DeviceSessionStaffBuilder get staff =>
      _$this._staff ??= DeviceSessionStaffBuilder();
  set staff(DeviceSessionStaffBuilder? staff) => _$this._staff = staff;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  DeviceSessionBuilder() {
    DeviceSession._defaults(this);
  }

  DeviceSessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _device = $v.device.toBuilder();
      _branch = $v.branch.toBuilder();
      _registerId = $v.registerId;
      _kitchenStationId = $v.kitchenStationId;
      _staff = $v.staff?.toBuilder();
      _serverTime = $v.serverTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceSession other) {
    _$v = other as _$DeviceSession;
  }

  @override
  void update(void Function(DeviceSessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceSession build() => _build();

  _$DeviceSession _build() {
    _$DeviceSession _$result;
    try {
      _$result = _$v ??
          _$DeviceSession._(
            device: device.build(),
            branch: branch.build(),
            registerId: registerId,
            kitchenStationId: kitchenStationId,
            staff: _staff?.build(),
            serverTime: BuiltValueNullFieldError.checkNotNull(
                serverTime, r'DeviceSession', 'serverTime'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'device';
        device.build();
        _$failedField = 'branch';
        branch.build();

        _$failedField = 'staff';
        _staff?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DeviceSession', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
