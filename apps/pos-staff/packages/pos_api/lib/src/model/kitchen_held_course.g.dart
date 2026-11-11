// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_held_course.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenHeldCourse extends KitchenHeldCourse {
  @override
  final String workspaceId;
  @override
  final String? resourceName;
  @override
  final String? areaId;
  @override
  final int course;
  @override
  final String courseName;
  @override
  final DateTime heldSince;
  @override
  final BuiltList<KitchenHeldLine> lines;

  factory _$KitchenHeldCourse(
          [void Function(KitchenHeldCourseBuilder)? updates]) =>
      (KitchenHeldCourseBuilder()..update(updates))._build();

  _$KitchenHeldCourse._(
      {required this.workspaceId,
      this.resourceName,
      this.areaId,
      required this.course,
      required this.courseName,
      required this.heldSince,
      required this.lines})
      : super._();
  @override
  KitchenHeldCourse rebuild(void Function(KitchenHeldCourseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenHeldCourseBuilder toBuilder() =>
      KitchenHeldCourseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenHeldCourse &&
        workspaceId == other.workspaceId &&
        resourceName == other.resourceName &&
        areaId == other.areaId &&
        course == other.course &&
        courseName == other.courseName &&
        heldSince == other.heldSince &&
        lines == other.lines;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, resourceName.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jc(_$hash, course.hashCode);
    _$hash = $jc(_$hash, courseName.hashCode);
    _$hash = $jc(_$hash, heldSince.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenHeldCourse')
          ..add('workspaceId', workspaceId)
          ..add('resourceName', resourceName)
          ..add('areaId', areaId)
          ..add('course', course)
          ..add('courseName', courseName)
          ..add('heldSince', heldSince)
          ..add('lines', lines))
        .toString();
  }
}

class KitchenHeldCourseBuilder
    implements Builder<KitchenHeldCourse, KitchenHeldCourseBuilder> {
  _$KitchenHeldCourse? _$v;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _resourceName;
  String? get resourceName => _$this._resourceName;
  set resourceName(String? resourceName) => _$this._resourceName = resourceName;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  int? _course;
  int? get course => _$this._course;
  set course(int? course) => _$this._course = course;

  String? _courseName;
  String? get courseName => _$this._courseName;
  set courseName(String? courseName) => _$this._courseName = courseName;

  DateTime? _heldSince;
  DateTime? get heldSince => _$this._heldSince;
  set heldSince(DateTime? heldSince) => _$this._heldSince = heldSince;

  ListBuilder<KitchenHeldLine>? _lines;
  ListBuilder<KitchenHeldLine> get lines =>
      _$this._lines ??= ListBuilder<KitchenHeldLine>();
  set lines(ListBuilder<KitchenHeldLine>? lines) => _$this._lines = lines;

  KitchenHeldCourseBuilder() {
    KitchenHeldCourse._defaults(this);
  }

  KitchenHeldCourseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceId = $v.workspaceId;
      _resourceName = $v.resourceName;
      _areaId = $v.areaId;
      _course = $v.course;
      _courseName = $v.courseName;
      _heldSince = $v.heldSince;
      _lines = $v.lines.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenHeldCourse other) {
    _$v = other as _$KitchenHeldCourse;
  }

  @override
  void update(void Function(KitchenHeldCourseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenHeldCourse build() => _build();

  _$KitchenHeldCourse _build() {
    _$KitchenHeldCourse _$result;
    try {
      _$result = _$v ??
          _$KitchenHeldCourse._(
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'KitchenHeldCourse', 'workspaceId'),
            resourceName: resourceName,
            areaId: areaId,
            course: BuiltValueNullFieldError.checkNotNull(
                course, r'KitchenHeldCourse', 'course'),
            courseName: BuiltValueNullFieldError.checkNotNull(
                courseName, r'KitchenHeldCourse', 'courseName'),
            heldSince: BuiltValueNullFieldError.checkNotNull(
                heldSince, r'KitchenHeldCourse', 'heldSince'),
            lines: lines.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        lines.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenHeldCourse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
