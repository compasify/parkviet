// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_visit_update_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleVisitUpdateInput extends VehicleVisitUpdateInput {
  @override
  final int expectedRevision;
  @override
  final String? plate;
  @override
  final VehicleType? vehicleType;
  @override
  final String? busOperatorId;
  @override
  final String? driverName;
  @override
  final String? driverPhone;
  @override
  final int? guestCount;
  @override
  final String? note;

  factory _$VehicleVisitUpdateInput(
          [void Function(VehicleVisitUpdateInputBuilder)? updates]) =>
      (VehicleVisitUpdateInputBuilder()..update(updates))._build();

  _$VehicleVisitUpdateInput._(
      {required this.expectedRevision,
      this.plate,
      this.vehicleType,
      this.busOperatorId,
      this.driverName,
      this.driverPhone,
      this.guestCount,
      this.note})
      : super._();
  @override
  VehicleVisitUpdateInput rebuild(
          void Function(VehicleVisitUpdateInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleVisitUpdateInputBuilder toBuilder() =>
      VehicleVisitUpdateInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleVisitUpdateInput &&
        expectedRevision == other.expectedRevision &&
        plate == other.plate &&
        vehicleType == other.vehicleType &&
        busOperatorId == other.busOperatorId &&
        driverName == other.driverName &&
        driverPhone == other.driverPhone &&
        guestCount == other.guestCount &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, plate.hashCode);
    _$hash = $jc(_$hash, vehicleType.hashCode);
    _$hash = $jc(_$hash, busOperatorId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, driverPhone.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleVisitUpdateInput')
          ..add('expectedRevision', expectedRevision)
          ..add('plate', plate)
          ..add('vehicleType', vehicleType)
          ..add('busOperatorId', busOperatorId)
          ..add('driverName', driverName)
          ..add('driverPhone', driverPhone)
          ..add('guestCount', guestCount)
          ..add('note', note))
        .toString();
  }
}

class VehicleVisitUpdateInputBuilder
    implements
        Builder<VehicleVisitUpdateInput, VehicleVisitUpdateInputBuilder> {
  _$VehicleVisitUpdateInput? _$v;

  int? _expectedRevision;
  int? get expectedRevision => _$this._expectedRevision;
  set expectedRevision(int? expectedRevision) =>
      _$this._expectedRevision = expectedRevision;

  String? _plate;
  String? get plate => _$this._plate;
  set plate(String? plate) => _$this._plate = plate;

  VehicleType? _vehicleType;
  VehicleType? get vehicleType => _$this._vehicleType;
  set vehicleType(VehicleType? vehicleType) =>
      _$this._vehicleType = vehicleType;

  String? _busOperatorId;
  String? get busOperatorId => _$this._busOperatorId;
  set busOperatorId(String? busOperatorId) =>
      _$this._busOperatorId = busOperatorId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _driverPhone;
  String? get driverPhone => _$this._driverPhone;
  set driverPhone(String? driverPhone) => _$this._driverPhone = driverPhone;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  VehicleVisitUpdateInputBuilder() {
    VehicleVisitUpdateInput._defaults(this);
  }

  VehicleVisitUpdateInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _plate = $v.plate;
      _vehicleType = $v.vehicleType;
      _busOperatorId = $v.busOperatorId;
      _driverName = $v.driverName;
      _driverPhone = $v.driverPhone;
      _guestCount = $v.guestCount;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleVisitUpdateInput other) {
    _$v = other as _$VehicleVisitUpdateInput;
  }

  @override
  void update(void Function(VehicleVisitUpdateInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleVisitUpdateInput build() => _build();

  _$VehicleVisitUpdateInput _build() {
    final _$result = _$v ??
        _$VehicleVisitUpdateInput._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision, r'VehicleVisitUpdateInput', 'expectedRevision'),
          plate: plate,
          vehicleType: vehicleType,
          busOperatorId: busOperatorId,
          driverName: driverName,
          driverPhone: driverPhone,
          guestCount: guestCount,
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
