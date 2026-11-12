// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendant_assignment_start_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AttendantAssignmentStartInput extends AttendantAssignmentStartInput {
  @override
  final String branchId;
  @override
  final String resourceId;
  @override
  final String staffId;
  @override
  final String? note;

  factory _$AttendantAssignmentStartInput(
          [void Function(AttendantAssignmentStartInputBuilder)? updates]) =>
      (AttendantAssignmentStartInputBuilder()..update(updates))._build();

  _$AttendantAssignmentStartInput._(
      {required this.branchId,
      required this.resourceId,
      required this.staffId,
      this.note})
      : super._();
  @override
  AttendantAssignmentStartInput rebuild(
          void Function(AttendantAssignmentStartInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AttendantAssignmentStartInputBuilder toBuilder() =>
      AttendantAssignmentStartInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AttendantAssignmentStartInput &&
        branchId == other.branchId &&
        resourceId == other.resourceId &&
        staffId == other.staffId &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, staffId.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AttendantAssignmentStartInput')
          ..add('branchId', branchId)
          ..add('resourceId', resourceId)
          ..add('staffId', staffId)
          ..add('note', note))
        .toString();
  }
}

class AttendantAssignmentStartInputBuilder
    implements
        Builder<AttendantAssignmentStartInput,
            AttendantAssignmentStartInputBuilder> {
  _$AttendantAssignmentStartInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _staffId;
  String? get staffId => _$this._staffId;
  set staffId(String? staffId) => _$this._staffId = staffId;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  AttendantAssignmentStartInputBuilder() {
    AttendantAssignmentStartInput._defaults(this);
  }

  AttendantAssignmentStartInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _resourceId = $v.resourceId;
      _staffId = $v.staffId;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AttendantAssignmentStartInput other) {
    _$v = other as _$AttendantAssignmentStartInput;
  }

  @override
  void update(void Function(AttendantAssignmentStartInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AttendantAssignmentStartInput build() => _build();

  _$AttendantAssignmentStartInput _build() {
    final _$result = _$v ??
        _$AttendantAssignmentStartInput._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'AttendantAssignmentStartInput', 'branchId'),
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'AttendantAssignmentStartInput', 'resourceId'),
          staffId: BuiltValueNullFieldError.checkNotNull(
              staffId, r'AttendantAssignmentStartInput', 'staffId'),
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
