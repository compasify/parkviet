// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_label.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CourseLabel extends CourseLabel {
  @override
  final int position;
  @override
  final String name;

  factory _$CourseLabel([void Function(CourseLabelBuilder)? updates]) =>
      (CourseLabelBuilder()..update(updates))._build();

  _$CourseLabel._({required this.position, required this.name}) : super._();
  @override
  CourseLabel rebuild(void Function(CourseLabelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CourseLabelBuilder toBuilder() => CourseLabelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CourseLabel &&
        position == other.position &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CourseLabel')
          ..add('position', position)
          ..add('name', name))
        .toString();
  }
}

class CourseLabelBuilder implements Builder<CourseLabel, CourseLabelBuilder> {
  _$CourseLabel? _$v;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CourseLabelBuilder() {
    CourseLabel._defaults(this);
  }

  CourseLabelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _position = $v.position;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CourseLabel other) {
    _$v = other as _$CourseLabel;
  }

  @override
  void update(void Function(CourseLabelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CourseLabel build() => _build();

  _$CourseLabel _build() {
    final _$result = _$v ??
        _$CourseLabel._(
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'CourseLabel', 'position'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CourseLabel', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
