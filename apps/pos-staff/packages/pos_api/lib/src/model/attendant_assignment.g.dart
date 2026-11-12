// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendant_assignment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AttendantAssignment extends AttendantAssignment {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String resourceId;
  @override
  final String resourceName;
  @override
  final String? timedSessionId;
  @override
  final AttendantStaff staff;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final int minutes;
  @override
  final Date businessDate;
  @override
  final String? note;

  factory _$AttendantAssignment(
          [void Function(AttendantAssignmentBuilder)? updates]) =>
      (AttendantAssignmentBuilder()..update(updates))._build();

  _$AttendantAssignment._(
      {required this.id,
      required this.branchId,
      required this.resourceId,
      required this.resourceName,
      this.timedSessionId,
      required this.staff,
      required this.startedAt,
      this.endedAt,
      required this.minutes,
      required this.businessDate,
      this.note})
      : super._();
  @override
  AttendantAssignment rebuild(
          void Function(AttendantAssignmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AttendantAssignmentBuilder toBuilder() =>
      AttendantAssignmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AttendantAssignment &&
        id == other.id &&
        branchId == other.branchId &&
        resourceId == other.resourceId &&
        resourceName == other.resourceName &&
        timedSessionId == other.timedSessionId &&
        staff == other.staff &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        minutes == other.minutes &&
        businessDate == other.businessDate &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, resourceName.hashCode);
    _$hash = $jc(_$hash, timedSessionId.hashCode);
    _$hash = $jc(_$hash, staff.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, minutes.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AttendantAssignment')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('resourceId', resourceId)
          ..add('resourceName', resourceName)
          ..add('timedSessionId', timedSessionId)
          ..add('staff', staff)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('minutes', minutes)
          ..add('businessDate', businessDate)
          ..add('note', note))
        .toString();
  }
}

class AttendantAssignmentBuilder
    implements Builder<AttendantAssignment, AttendantAssignmentBuilder> {
  _$AttendantAssignment? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _resourceName;
  String? get resourceName => _$this._resourceName;
  set resourceName(String? resourceName) => _$this._resourceName = resourceName;

  String? _timedSessionId;
  String? get timedSessionId => _$this._timedSessionId;
  set timedSessionId(String? timedSessionId) =>
      _$this._timedSessionId = timedSessionId;

  AttendantStaffBuilder? _staff;
  AttendantStaffBuilder get staff => _$this._staff ??= AttendantStaffBuilder();
  set staff(AttendantStaffBuilder? staff) => _$this._staff = staff;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  int? _minutes;
  int? get minutes => _$this._minutes;
  set minutes(int? minutes) => _$this._minutes = minutes;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  AttendantAssignmentBuilder() {
    AttendantAssignment._defaults(this);
  }

  AttendantAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _resourceId = $v.resourceId;
      _resourceName = $v.resourceName;
      _timedSessionId = $v.timedSessionId;
      _staff = $v.staff.toBuilder();
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _minutes = $v.minutes;
      _businessDate = $v.businessDate;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AttendantAssignment other) {
    _$v = other as _$AttendantAssignment;
  }

  @override
  void update(void Function(AttendantAssignmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AttendantAssignment build() => _build();

  _$AttendantAssignment _build() {
    _$AttendantAssignment _$result;
    try {
      _$result = _$v ??
          _$AttendantAssignment._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'AttendantAssignment', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'AttendantAssignment', 'branchId'),
            resourceId: BuiltValueNullFieldError.checkNotNull(
                resourceId, r'AttendantAssignment', 'resourceId'),
            resourceName: BuiltValueNullFieldError.checkNotNull(
                resourceName, r'AttendantAssignment', 'resourceName'),
            timedSessionId: timedSessionId,
            staff: staff.build(),
            startedAt: BuiltValueNullFieldError.checkNotNull(
                startedAt, r'AttendantAssignment', 'startedAt'),
            endedAt: endedAt,
            minutes: BuiltValueNullFieldError.checkNotNull(
                minutes, r'AttendantAssignment', 'minutes'),
            businessDate: BuiltValueNullFieldError.checkNotNull(
                businessDate, r'AttendantAssignment', 'businessDate'),
            note: note,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'staff';
        staff.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AttendantAssignment', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
