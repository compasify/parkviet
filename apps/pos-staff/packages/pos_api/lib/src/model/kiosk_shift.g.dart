// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_shift.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskShift extends KioskShift {
  @override
  final String id;
  @override
  final String? registerId;
  @override
  final String status;
  @override
  final String openingFloat;
  @override
  final String ownerId;
  @override
  final String? openedAt;
  @override
  final String? businessDate;

  factory _$KioskShift([void Function(KioskShiftBuilder)? updates]) =>
      (KioskShiftBuilder()..update(updates))._build();

  _$KioskShift._(
      {required this.id,
      this.registerId,
      required this.status,
      required this.openingFloat,
      required this.ownerId,
      this.openedAt,
      this.businessDate})
      : super._();
  @override
  KioskShift rebuild(void Function(KioskShiftBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskShiftBuilder toBuilder() => KioskShiftBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskShift &&
        id == other.id &&
        registerId == other.registerId &&
        status == other.status &&
        openingFloat == other.openingFloat &&
        ownerId == other.ownerId &&
        openedAt == other.openedAt &&
        businessDate == other.businessDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, registerId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, openingFloat.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
    _$hash = $jc(_$hash, openedAt.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskShift')
          ..add('id', id)
          ..add('registerId', registerId)
          ..add('status', status)
          ..add('openingFloat', openingFloat)
          ..add('ownerId', ownerId)
          ..add('openedAt', openedAt)
          ..add('businessDate', businessDate))
        .toString();
  }
}

class KioskShiftBuilder implements Builder<KioskShift, KioskShiftBuilder> {
  _$KioskShift? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _registerId;
  String? get registerId => _$this._registerId;
  set registerId(String? registerId) => _$this._registerId = registerId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _openingFloat;
  String? get openingFloat => _$this._openingFloat;
  set openingFloat(String? openingFloat) => _$this._openingFloat = openingFloat;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

  String? _openedAt;
  String? get openedAt => _$this._openedAt;
  set openedAt(String? openedAt) => _$this._openedAt = openedAt;

  String? _businessDate;
  String? get businessDate => _$this._businessDate;
  set businessDate(String? businessDate) => _$this._businessDate = businessDate;

  KioskShiftBuilder() {
    KioskShift._defaults(this);
  }

  KioskShiftBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _registerId = $v.registerId;
      _status = $v.status;
      _openingFloat = $v.openingFloat;
      _ownerId = $v.ownerId;
      _openedAt = $v.openedAt;
      _businessDate = $v.businessDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskShift other) {
    _$v = other as _$KioskShift;
  }

  @override
  void update(void Function(KioskShiftBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskShift build() => _build();

  _$KioskShift _build() {
    final _$result = _$v ??
        _$KioskShift._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'KioskShift', 'id'),
          registerId: registerId,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'KioskShift', 'status'),
          openingFloat: BuiltValueNullFieldError.checkNotNull(
              openingFloat, r'KioskShift', 'openingFloat'),
          ownerId: BuiltValueNullFieldError.checkNotNull(
              ownerId, r'KioskShift', 'ownerId'),
          openedAt: openedAt,
          businessDate: businessDate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
