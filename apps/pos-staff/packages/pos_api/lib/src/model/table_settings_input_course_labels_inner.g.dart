// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_settings_input_course_labels_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableSettingsInputCourseLabelsInner
    extends TableSettingsInputCourseLabelsInner {
  @override
  final String name;

  factory _$TableSettingsInputCourseLabelsInner(
          [void Function(TableSettingsInputCourseLabelsInnerBuilder)?
              updates]) =>
      (TableSettingsInputCourseLabelsInnerBuilder()..update(updates))._build();

  _$TableSettingsInputCourseLabelsInner._({required this.name}) : super._();
  @override
  TableSettingsInputCourseLabelsInner rebuild(
          void Function(TableSettingsInputCourseLabelsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableSettingsInputCourseLabelsInnerBuilder toBuilder() =>
      TableSettingsInputCourseLabelsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableSettingsInputCourseLabelsInner && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableSettingsInputCourseLabelsInner')
          ..add('name', name))
        .toString();
  }
}

class TableSettingsInputCourseLabelsInnerBuilder
    implements
        Builder<TableSettingsInputCourseLabelsInner,
            TableSettingsInputCourseLabelsInnerBuilder> {
  _$TableSettingsInputCourseLabelsInner? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  TableSettingsInputCourseLabelsInnerBuilder() {
    TableSettingsInputCourseLabelsInner._defaults(this);
  }

  TableSettingsInputCourseLabelsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableSettingsInputCourseLabelsInner other) {
    _$v = other as _$TableSettingsInputCourseLabelsInner;
  }

  @override
  void update(
      void Function(TableSettingsInputCourseLabelsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableSettingsInputCourseLabelsInner build() => _build();

  _$TableSettingsInputCourseLabelsInner _build() {
    final _$result = _$v ??
        _$TableSettingsInputCourseLabelsInner._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TableSettingsInputCourseLabelsInner', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
