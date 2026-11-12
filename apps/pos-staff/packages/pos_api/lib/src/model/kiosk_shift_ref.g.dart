// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_shift_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskShiftRef extends KioskShiftRef {
  @override
  final String id;
  @override
  final String? openedAt;
  @override
  final String? businessDate;

  factory _$KioskShiftRef([void Function(KioskShiftRefBuilder)? updates]) =>
      (KioskShiftRefBuilder()..update(updates))._build();

  _$KioskShiftRef._({required this.id, this.openedAt, this.businessDate})
      : super._();
  @override
  KioskShiftRef rebuild(void Function(KioskShiftRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskShiftRefBuilder toBuilder() => KioskShiftRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskShiftRef &&
        id == other.id &&
        openedAt == other.openedAt &&
        businessDate == other.businessDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, openedAt.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskShiftRef')
          ..add('id', id)
          ..add('openedAt', openedAt)
          ..add('businessDate', businessDate))
        .toString();
  }
}

class KioskShiftRefBuilder
    implements Builder<KioskShiftRef, KioskShiftRefBuilder> {
  _$KioskShiftRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _openedAt;
  String? get openedAt => _$this._openedAt;
  set openedAt(String? openedAt) => _$this._openedAt = openedAt;

  String? _businessDate;
  String? get businessDate => _$this._businessDate;
  set businessDate(String? businessDate) => _$this._businessDate = businessDate;

  KioskShiftRefBuilder() {
    KioskShiftRef._defaults(this);
  }

  KioskShiftRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _openedAt = $v.openedAt;
      _businessDate = $v.businessDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskShiftRef other) {
    _$v = other as _$KioskShiftRef;
  }

  @override
  void update(void Function(KioskShiftRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskShiftRef build() => _build();

  _$KioskShiftRef _build() {
    final _$result = _$v ??
        _$KioskShiftRef._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'KioskShiftRef', 'id'),
          openedAt: openedAt,
          businessDate: businessDate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
