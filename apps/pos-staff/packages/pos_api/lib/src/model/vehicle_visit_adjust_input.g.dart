// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_visit_adjust_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleVisitAdjustInput extends VehicleVisitAdjustInput {
  @override
  final int expectedRevision;
  @override
  final int? guestCount;
  @override
  final String? commissionAmount;
  @override
  final String note;
  @override
  final String approvalId;

  factory _$VehicleVisitAdjustInput(
          [void Function(VehicleVisitAdjustInputBuilder)? updates]) =>
      (VehicleVisitAdjustInputBuilder()..update(updates))._build();

  _$VehicleVisitAdjustInput._(
      {required this.expectedRevision,
      this.guestCount,
      this.commissionAmount,
      required this.note,
      required this.approvalId})
      : super._();
  @override
  VehicleVisitAdjustInput rebuild(
          void Function(VehicleVisitAdjustInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleVisitAdjustInputBuilder toBuilder() =>
      VehicleVisitAdjustInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleVisitAdjustInput &&
        expectedRevision == other.expectedRevision &&
        guestCount == other.guestCount &&
        commissionAmount == other.commissionAmount &&
        note == other.note &&
        approvalId == other.approvalId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, commissionAmount.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleVisitAdjustInput')
          ..add('expectedRevision', expectedRevision)
          ..add('guestCount', guestCount)
          ..add('commissionAmount', commissionAmount)
          ..add('note', note)
          ..add('approvalId', approvalId))
        .toString();
  }
}

class VehicleVisitAdjustInputBuilder
    implements
        Builder<VehicleVisitAdjustInput, VehicleVisitAdjustInputBuilder> {
  _$VehicleVisitAdjustInput? _$v;

  int? _expectedRevision;
  int? get expectedRevision => _$this._expectedRevision;
  set expectedRevision(int? expectedRevision) =>
      _$this._expectedRevision = expectedRevision;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  String? _commissionAmount;
  String? get commissionAmount => _$this._commissionAmount;
  set commissionAmount(String? commissionAmount) =>
      _$this._commissionAmount = commissionAmount;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  VehicleVisitAdjustInputBuilder() {
    VehicleVisitAdjustInput._defaults(this);
  }

  VehicleVisitAdjustInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _guestCount = $v.guestCount;
      _commissionAmount = $v.commissionAmount;
      _note = $v.note;
      _approvalId = $v.approvalId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleVisitAdjustInput other) {
    _$v = other as _$VehicleVisitAdjustInput;
  }

  @override
  void update(void Function(VehicleVisitAdjustInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleVisitAdjustInput build() => _build();

  _$VehicleVisitAdjustInput _build() {
    final _$result = _$v ??
        _$VehicleVisitAdjustInput._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision, r'VehicleVisitAdjustInput', 'expectedRevision'),
          guestCount: guestCount,
          commissionAmount: commissionAmount,
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'VehicleVisitAdjustInput', 'note'),
          approvalId: BuiltValueNullFieldError.checkNotNull(
              approvalId, r'VehicleVisitAdjustInput', 'approvalId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
